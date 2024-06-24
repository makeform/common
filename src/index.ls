/*
supported ld selector:
 - Done:
   - error
   - error-root
   - limitation
   - note
   - is-required
   - desc
   - display ( data-display: inline / block )

 - TBD
   - base
   - label
   - variant
   - input
   - has-unit
   - content
*/


module.exports =
  pkg:
    name: "@makeform/common", extend: {name: "@makeform/base"}
    dependencies: []
    i18n: {
      en: "error": "error"
      "zh-TW": "error": "有錯誤"
    }
  init: (opt) ->
    opt.pubsub.on \subinit, (o = {}) ~>
      opt.pubsub.fire \init, mod: mod(opt, o.mod)
mod = ({root, ctx, data, parent, t}, submod) -> 
  {ldview} = ctx
  mod = 
    init: ->
      @mod.info = lc = {}
      @mod.child = {}
      @remeta = (v) ->
        lc.meta = v
        lc.config = v.config or {}
        lc.display = v.config.display or \block
      @on \meta, ~> @remeta @serialize!
      @remeta data
      if !root => return
      @mod.info.view = new ldview do
        root: root
        text:
          label: ~> t(lc.meta.title or 'untitled')
          variant: ({node}) ~> t(lc.config.variant or '')
        handler:
          "@": ({node}) ~>
            node.classList.toggle \m-inline, lc.display != \block
            node.classList.toggle \has-error, @status! == 2
          base: ({node}) ~>
            node.classList.toggle \form-group, (lc.display == \block)
            node.classList.toggle \has-variant, !!lc.config.variant
          "is-required": ({node}) ~>
            node.classList.toggle \d-none, !lc.meta.is-required
          desc: ({node}) ~>
            node.classList.toggle \d-none, !lc.meta.desc
            node.innerText = t(lc.meta.desc or '') or ''
          "display": ({node}) ~>
            node.classList.toggle \d-none, node.getAttribute(\data-display) != lc.display
          "error-root": ({node}) ~> node.classList.toggle \manual, @status! != 2
          limitation: ({node}) ~>
            v = t(lc.config.limitation or '')
            node.classList.toggle \d-none, !v
            node.innerHTML = "• #v"
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
              if Array.isArray(lc.config.note) => lc.config.note
              else if lc.config.note => [lc.config.note]
              else []
            key: -> it
            handler: ({node, data}) ->
              v = t data
              node.innerText = if v => "• #{v}" else ''
              node.classList.toggle \d-none, !v
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
