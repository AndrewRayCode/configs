if !exists('b:splitjoin_split_callbacks')
  let b:splitjoin_split_callbacks = [
        \ 'sj#js#SplitArray',
        \ 'sj#js#SplitObjectLiteral',
        \ 'sj#js#SplitFunction'
        \ ]
endif

if !exists('b:splitjoin_join_callbacks')
  let b:splitjoin_join_callbacks = [
        \ 'sj#js#JoinArray',
        \ 'sj#js#JoinFunction',
        \ 'sj#js#JoinObjectLiteral'
        \ ]
endif
