# Change Logs

## v3.1.0 (upcoming)

 - add term editing dialog
 - add i18n for minibar tips


## v3.0.1

 - use cps-hover-host and cps-hover-reveal to replace cps-hover class


## v3.0.0

 - support `@grantdash/composer` host
 - tweak margin between head and body
 - tweak limitation decoration


## v2.0.2

 - ensure ld-scope to ensure correct ld selector scoping


## v2.0.1

 - fix bug: fallback `config` to `{}` when not given to prevent exception


## v2.0.0

 - support `head`, `body` and `foot` plugs when `widget` is not applied.
 - add plug fallbacks for head, body and foot
 - add `has-variant` class from `@makeform/input` since `variant` is a common-based feature
 - explicitly set `manual` only if `has-tips` is available
 - add `notes` class, and add margin-top only if notes is not empty to prevent unwanted margin.


## v1.0.5

 - rebuild for missing artifacts


## v1.0.4

 - use `overflow-wrap` to break super long text instead of `word-break: break-all` which breaks all texts


## v1.0.3

 - always update local meta when rendering to prevent unsynchronized status.


## v1.0.2

 - add `has-error` class at root node when status is 2


## v1.0.1

 - ignore `nested` error.


## v1.0.0

 - init release

