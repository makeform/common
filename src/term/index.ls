module.exports =
  pkg:
    dependencies: [
    * name: \ldview
    * name: \@plotdb/form
    * name: \ldcover
    * name: \ldcover, type: \css, global: true
    ]
    i18n:
      "zh-TW:":
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
  init: ({root, ctx, t, i18n}) ->
    {ldcover,form} = ctx
    opsets = form.opset.list!
    for opset in opsets => i18n.add-resource-bundles opset.i18n if opset.i18n
    mod = @{}mod
    mod.ldcv = new ldcover root: root
    mod.ldcv.on \data, (p) ~>
      mod.terms = if Array.isArray(p) => JSON.parse(JSON.stringify(p)) else []
      mod.view.render!
    mod.view = new ldview do
      root: root
      action: click:
        add: ({views}) ->
          opset = opsets.0
          op = [{k,v} for k,v of opset.ops].0 or {}
          term =
            id: Math.random!toString(36)substring(2)
            opset: opset.id or opset.name
            op: op.k
          mod[]terms.push term
          views.0.render!
        close: ->
          mod.ldcv.set term: (mod.terms or [])
      handler:
        term:
          list: -> mod[]terms
          key: -> it.id
          view:
            action:
              click:
                enabled: ({ctx, views}) -> ctx.enabled = !ctx.enabled; views.0.render!
                delete: ({ctx, views, ctxs}) -> ctxs.0.splice(ctxs.0.indexOf(ctx), 1); views.1.render!
              input:
                msg: ({node, ctx}) -> ctx.msg = node.value
              change:
                msg: ({node, ctx}) -> ctx.msg = node.value
                opset: ({node, ctx, views}) ->
                  ctx.opset = node.value
                  views.0.render!
                op: ({node, ctx, views}) ->
                  ctx.op = node.value
                  views.0.render!
            handler:
              msg: ({node, ctx, ctxs}) -> node.value = ctxs.0?msg or ''
              enabled: ({node, ctx}) -> node.classList.toggle \on, !!ctx.enabled
              "opset-option":
                list: -> opsets
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
              "op-cfg":
                list: ({ctx}) ->
                  if !(opset = form.opset.get(ctx.opset)) => return []
                  if !(op = opset.get-op(ctx.op)) => return []
                  [{k,v} for k,v of (op?config or {})]
                key: -> it.k
                view:
                  action:
                    change: value: ({node, ctx, ctxs}) -> ctxs.0{}config[ctx.k] = node.value
                    input: value: ({node, ctx, ctxs}) -> ctxs.0{}config[ctx.k] = node.value
                  handler:
                    value: ({node, ctx, ctxs}) -> node.value = ctxs.0?config?[ctx.k] or ''
                    name: ({node, ctx}) -> node.textContent = t(ctx?v?name or ctx?k)
                    hint: ({node, ctx}) -> node.textContent = t(ctx?v?hint or '')

