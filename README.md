# @makeform/common

supported meta:

 - `title`: field title.
 - `desc`: description of this field.
 - `isRequired`: true if this field is required.


supported configs:

 - `note`: a list of string showing additional note about this field.
 - `limitation`: a string shown as the main requirement of this field.
 - `display`: either `inline` or `block`. The main difference of these display is:
   - `inline`: consider the widget as to be used inline, without header.
     - widget may be shown as `block` style element in CSS, so user should wrap widget properly.
   - `block`: header is shown.


## interfae

`@makeform/common` provides additional members for child block to access, which are created by `@makeform/common`:

 - `info`
   - `meta`: the meta object
   - `config`: the config object
   - `display`: display mode, either `inline` of `block`. when omitted, default to `block`.
   - `view`: ldview object created by `@makeform/common`.
 - `child`
   - preserved for child block to use


## default classes

Following are classes used by @makeform/common and all blocks inheriting `@makeform/common`. While you can build the exactly same logic or design conventions with different class names by your own, following these conventions makes it easier to customize your blocks along with the default blocks in headless manner.

 - functional classes:
   - `m-view`: for nodes that should only be shown in view mode.
   - `m-edit`: for nodes that should only be shown in view mode.
 - style classes:
   - `mf-note`: decorator for note nodes.


## License

MIT
