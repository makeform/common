
    module.exports =
      pkg:
        name: "@makeform/input", extend: {name: "@makeform/base"}
        dependencies: [
          {name: "marked", version: "main", path: "marked.min.js"}
        ]
        i18n:
          "en": "單位": "unit"
          "zh-TW": "unit": "單位"
      init: (opt) -> opt.pubsub.fire \init, mod: mod(opt)
    mod = ({root, ctx, data, parent, t}) -> 

      {ldview,marked} = ctx
      lc = {}
      remeta = (v) ->
        lc.meta = v
        lc.cfg = v.config
        lc.display = v.config.display or \block
      remeta data
      init: ->
        @on \meta, ~> remeta @serialize!
        @on \change, (v) ~>
          c = @content v
          if !(c?) => c = ''
          if @view.get(\input).value == c => return
          @view.get(\input).value = c
          @view.render <[preview input content]>
        handler = ({node}) ~>
          if @content(v = @value!) == (nv = node.value) => return
          if v and typeof(v) == \object => v.v = nv
          else v = {v: nv}
          @value v
        @view = view = new ldview do
          root: root
          action:
            input: input: handler
            change:
              input: handler
              "enable-markdown-input": ({node}) ~>
                lc.markdown = node.checked
                if !lc.markdown => lc.preview = false
                if typeof(v = @value!) != \object => v = {v: v}
                v.markdown = lc.markdown
                @value v
                view.render!
            click:
              mode: ({node}) ->
                lc.preview = if node.getAttribute(\data-name) == \preview => true else false
                view.render!
          text:
            variant: ({node}) ~> t(lc.cfg.variant or '')
            unit: ({node}) ~> t(lc.cfg.unit or '')
          handler:

            "has-unit": ({node}) ~>
              node.classList.toggle \d-none, !lc.cfg.unit
            "enable-markdown": ({node}) ~> node.classList.toggle \d-none, !lc.cfg.show-markdown-option
            base: ({node}) ~>
              node.classList.toggle \form-group, (lc.display == \block)
              node.classList.toggle \has-variant, !!lc.cfg.variant
            preview: ({node}) ~>
              if !view => return
              node.classList.toggle \d-none, !lc.preview
              node.innerHTML = marked.parse view.get(\input).value

            input: ({node}) ~>
              readonly = !!lc.meta.readonly
              if readonly => node.setAttribute \readonly, true
              else node.removeAttribute \readonly
              node.classList.toggle \is-invalid, @status! == 2
              if lc.cfg.placeholder => node.setAttribute \placeholder, lc.cfg.placeholder
              else node.removeAttribute \placeholder
            content: ({node}) ~>
              val = @content!
              text = if @is-empty! => "n/a"
              else val + (if lc.cfg.unit => that else "")
              node.classList.toggle \text-muted, @is-empty!
              node.innerText = text
              #ret = marked.parse view.get(\input).value

      render: ->
        @view.render!

      is-empty: (v) ->
        v = @content(v)
        return (typeof(v) == \undefined) or (typeof(v) == \string and v.trim! == "") or v == null
      content: (v) -> if v and typeof(v) == \object => v.v else v

