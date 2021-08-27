" =============================================================================
" ====
" =====
" ======
" Macvim Overrides:
" ======
" =====
" ====
" ===
" =============================================================================

" See https://stackoverflow.com/a/13437393/743464
" Spectacle shortcuts bind ctrl-command-left, etc, to move windows around.
" MacVim by default maps these to commands in the tools menu. To override
" those apparently they have to be in a .gvimrc, not your .vimrc

macm Tools.List\ Errors<Tab>:cl		key=<nop>
macm Tools.Next\ Error<Tab>:cn		key=<nop>
macm Tools.Previous\ Error<Tab>:cp		key=<nop>
macm Tools.Older\ List<Tab>:cold		key=<nop>
macm Tools.Newer\ List<Tab>:cnew		key=<nop>

" Fix for bug https://github.com/macvim-dev/macvim/issues/806#issuecomment-446551760
macm Edit.Find.Use\ Selection\ for\ Find key=<nop>
