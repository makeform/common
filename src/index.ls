module.exports =
  pkg:
    name: "@makeform/common"
    extend: name: \@makeform/base, dom: \overwrite
    host: name: \@grantdash/composer
    dependencies: [
    * name: \ldview
    ]
    i18n:
      en:
        "error": "error"
        "add": "Add"
        "New note": "New note"
        minibar:
          "add-note": title: "Add Note"
          term: title: "Add Term"
        config:
          isRequired: name: "required", desc: "required if enabled"
          readonly: name: "read only", desc: "read only if enabled"
          display: name: "display mode", desc: "how this widget is layouted (block or inline with title)"
      "zh-TW":
        "error": "有錯誤"
        "add": "增加"
        "New note": "新註記說明文字"
        minibar:
          "add-note": title: "加入註解"
          term: title: "加入條件"
        config:
          isRequired: name: "必填", desc: "若啟用，則欄位為必填；否則為選填"
          readonly: name: "唯讀", desc: "若啟用，則欄位唯讀；否則可填寫"
          display: name: "顯示模式", desc: "設定此元件如何顯示 區塊 或 行內(無標題)"
  client: (bid) ->
    config: (opt = {}) ~>
      data = @hitf.get!
      if !(obj = opt.config) => return data{readonly, is-required, config}
      data = @ctx.ldview.merge data, obj
      @widget.deserialize data
      @hitf.set {data}
    meta:
      is-required: type: \boolean, default: false, name: "config.isRequired.name", desc: "config.isRequired.desc"
      readonly: type: \boolean, default: false, name: "config.readonly.name", desc: "config.readonly.desc"
      config:
        display:
          type: \choice, default: \block
          values: [{name: \區塊, value: \block}, {name: \行內, value: \inline}]
          name: "config.display.name", desc: "config.display.desc"
    minibar: [
    * tip: "minibar.add-note.title", icon: \i-list, handler: ~> @add-note!
    * tip: "minibar.term.title", icon: \i-checklist
      handler: ~>
        (ret) <~ @mod.opt.manager.from {name: \@makeform/common, path: \term}, {root: document.body} .then _
        meta = @widget.serialize!
        ({term = []} = {}) <~ ret.interface.get meta.term .then _
        if !Array.isArray(term) => return
        @widget.deserialize(meta <<< {term})
        @hitf.set {data: meta}
    ]
    render: ~> @widget.mod.info.view.render!
  init: (opt) ->
    @{}mod.opt = opt
    opt.pubsub.on \inited, (o = {}) ~> @ <<< o
    opt.pubsub.on \subinit, (o = {}) ~> opt.pubsub.fire \init, mod: mod.apply @, [opt, o.mod]
mod = ({root, ctx, data, parent, t, manager, i18n, host}, submod) ->
  {ldview} = ctx
  base = @
  mod =
    init: ->
      base <<<
        ctx: ctx
        hitf: hitf = @mod.hitf
        add-note: ~>
          new-entry =
            key: "#{Date.now!}-#{Math.random!toString(36)substring(2)}"
            label: hitf.wrap "#{i18n.language}": t("新節點")
          hitf.get!{}config[]note.push new-entry
          hitf.set!
          @mod.info.view.render \note

      @mod.info = lc = {}
      @mod.child = {}
      @remeta = (v = {}) ->
        lc.meta = v
        lc.config = v.config or {}
        lc.display = lc.config.display or \block
      @on <[meta]>, (m) ~> @remeta m
      @remeta data
      if !root => return
      @mod.info.view = new ldview do
        root: root
        text:
          variant: ({node}) ~> t(lc.config.variant or '')
        handler:
          label: hitf.render {path: \title}
          "@": ({node}) ~>
            node.classList.toggle \m-inline, lc.display != \block
            node.classList.toggle \has-error, @status! == 2
          base: ({node}) ~>
            node.classList.toggle \form-group, (lc.display == \block)
            node.classList.toggle \has-variant, !!lc.config.variant
          "is-required": ({node}) ~>
            node.classList.toggle \d-none, !lc.meta.is-required
          desc: hitf.render {path: \desc}
          "display": ({node}) ~> node.classList.toggle \d-none, node.getAttribute(\data-display) != lc.display
          "error-root": ({node}) ~>
            if node.classList.contains \has-tips =>
              node.classList.toggle \manual, @status! != 2
          limitation: hitf.render {path: "config.limitation"}
          error:
            list: ~>
              if (s = @status!) != 2 => return []
              ret = @_errors.slice(0, 1) ++ (if @_errors.length > 1 => ["..."] else [])
              # nested is an error indicating there are errors in form managers owned by this widget.
              # we skip showing nested and let those widgets show by themselves.
              ret.filter -> it != \nested
            text: ({data}) -> t data
          note:
            list: ~>
              notes = hitf.get!?config?note or []
              if Array.isArray(notes) => notes else if notes => [notes] else []
            key: -> it.key or it
            view:
              handler: text: hitf.render obj: ({ctx}) -> ctx.label or ctx
              action: click:
                # init: always return {} for editing. otherwise return original ctx.label
                text: hitf.edit obj: ({ctx, init}) -> ctx{}label
                remove: ({node, ctx, views}) ~>
                  cfg = hitf.get!{}config
                  cfg.note = cfg.[]note.filter -> it.key != ctx.key
                  hitf.set!
        action: click:
          "add-note": ({node, views}) ~> base.add-note!
          editable: hitf.edit!
      submod.init.apply @

    render: ->
      # meta may be updated without firing meta event (for re-init calls for example)
      # so we should always get the latest meta
      # this may be bad in performance but we can optimize this later. (TODO)
      @remeta @serialize!
      if @mod.info.view => @mod.info.view.render!
      submod.render.apply @
  ret = {} <<< submod <<< mod
  ret
