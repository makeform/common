module.exports =
  pkg:
    dependencies: [
    * name: \ldview
    * name: \@plotdb/form
    * name: \ldcover
    * name: \ldcover, type: \css, global: true
    * name: \@plotdb/konfig
    * name: \@plotdb/konfig, path: "konfig.widget.bootstrap.min.js"
    ]
    i18n:
      "zh-TW":
        "validation-rules": "表單驗證條件"
        "ruleset": "規則集"
        "rule": "規則"
        "errmsg": "錯誤訊息"
        "new": "新增"
        "ok": "完成"
        "cancel": "取消"
      "en":
        "validation-rules": "Validation Rules"
        "ruleset": "Rule Set"
        "rule": "Rule"
        "errmsg": "Error Message"
        "new": "New"
        "ok": "OK"
        "cancel": "Cancel"

  interface: -> @mod.ldcv
  init: ({root, ctx, t, i18n, manager}) ->
    {ldcover, form, konfig} = ctx
    mod = @{}mod
    mod.widget = null
    mod.opsets = form.opset.list!
    for opset in mod.opsets =>
      for lng, res of opset.i18n or {} => block.i18n.add-resource-bundle lng, '', res, true, true
    get-opsets = -> form.opset.list {valdef: if mod.widget => mod.widget.valdef! else null}
    get-valspec = ->
      if !mod.widget => null
      else mod.widget.valspec!
    mod.ldcv = new ldcover root: root
    mod.ldcv.on \data, ({terms, widget} = {}) ~>
      mod.widget = widget or null
      mod.terms = if Array.isArray(terms) => JSON.parse(JSON.stringify(terms)) else []
      mod.view.render!
    mod.view = new ldview do
      root: root
      action: click:
        add: ->
          opset = get-opsets!0 or {}
          op = opset.get-ops!0 or {}
          term = opset: (opset.id or opset.name), op: op.id
          mod[]terms.push term
          mod.view.render!
        close: -> mod.ldcv.set term: (mod.terms or [])
      handler:
        term:
          list: -> mod[]terms
          key: -> it.id
          view:
            action:
              click:
                enabled: ({ctx, views}) -> ctx.enabled = !ctx.enabled; views.0.render!
                delete: ({ctx, views}) ->
                  idx = mod.terms.findIndex -> it.id == ctx.id
                  if ~idx => mod.terms.splice idx, 1
                  views.1.render!
              input:
                msg: ({node, ctx}) -> ctx.msg = node.value
              change:
                msg: ({node, ctx}) -> ctx.msg = node.value
                opset: ({node, ctx, views}) ->
                  ctx.opset = node.value
                  opset = form.opset.get ctx.opset
                  ctx.op = opset?get-ops!0?id or ''
                  ctx.config = {}
                  views.0.render!
                op: ({node, ctx, views}) ->
                  ctx.op = node.value
                  views.0.render!
            handler:
              idx: ({node, ctx}) -> 
                idx = mod.terms.findIndex -> it.id == ctx.id
                node.textContent = (idx + 1)
              msg: ({node, ctx}) -> node.value = ctx.msg or ''
              enabled: ({node, ctx}) -> node.classList.toggle \on, !!ctx.enabled
              "opset-option":
                list: -> get-opsets!
                key: -> it.id or it.name
                view:
                  handler: "@": ({node, ctx, ctxs}) ->
                    node.value = ctx.id or ctx.name
                    node.textContent = t(ctx.name or ctx.id)
                    if node.value == ctxs.0.opset => node.parentNode.value = node.value
              "op-option":
                list: ({ctx}) ->
                  opset = form.opset.get(ctx.opset)
                  [{k, v} for k, v of (opset?ops or {})]
                key: -> it.k
                view:
                  handler: "@": ({node, ctx, ctxs}) ->
                    node.value = ctx.v.id or ctx.v.name or ctx.k
                    node.textContent = t(ctx.v.name or ctx.v.id or ctx.k)
                    if node.value == ctxs.0.op => node.parentNode.value = node.value
              "op-cfg-root": ({node, ctx}) ~>
                node._ctx = ctx
                opset = form.opset.get(ctx.opset)
                op = if opset => opset.get-op(ctx.op) else null
                valspec = get-valspec!
                cfg-schema = if op => op.get-config(valspec) else {}
                meta = {}
                for k, v of cfg-schema => meta[k] = {} <<< v <<< {name: v.name or k}
                op-changed = node._last-op != ctx.op or node._last-opset != ctx.opset
                node._last-op = ctx.op
                node._last-opset = ctx.opset
                if op-changed and node._kfg => ctx.config = {}
                if !node._kfg
                  ctrl-el = document.createElement \div
                  ctrl-el.classList.toggle \flex-grow-1, true
                  ctrl-el.setAttribute \ld-each, \ctrl
                  ctrl-el.setAttribute \ld-scope, ''
                  node.appendChild ctrl-el
                  typemap = (name) ->
                    name: \@makeform/common, version: \main, path: "term/konfig/#name/index.html"
                  node._kfg = new konfig {root: node, view: \simple, manager, typemap}
                  node._kfg.on \change, (v) ~> node._ctx.config = v
                  saved-config = ctx.config or {}
                  node._kfg.init!
                    .then ~> node._kfg.meta {meta, config: saved-config}
                else
                  if op-changed
                    node._kfg.meta {meta, config: (ctx.config or {})}
                  else
                    node._kfg.set (ctx.config or {})

