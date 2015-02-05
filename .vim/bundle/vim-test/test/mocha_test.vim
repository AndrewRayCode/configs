source test/helpers.vim

function! test#shell(cmd, ...) abort
  let g:test#last_command = substitute(a:cmd, ' --compilers \S\+', '', '')
endfunction

describe "Mocha"

  before
    cd test/fixtures/mocha
  end

  after
    call Teardown()
    cd -
  end

  context "on nearest tests"
    it "runs JavaScript"
      view +1 test/normal.js
      TestNearest

      Expect g:test#last_command == 'mocha test/normal.js --grep ''Addition'''

      view +2 test/normal.js
      TestNearest

      Expect g:test#last_command == 'mocha test/normal.js --grep ''adds two numbers'''
    end

    it "runs CoffeeScript"
      view +1 test/normal.coffee
      TestNearest

      Expect g:test#last_command == 'mocha test/normal.coffee --grep ''Addition'''

      view +2 test/normal.coffee
      TestNearest

      Expect g:test#last_command == 'mocha test/normal.coffee --grep ''adds two numbers'''
    end
  end

  it "runs file test if nearest test couldn't be found"
    view +1 test/normal.js
    normal O
    TestNearest

    Expect g:test#last_command == 'mocha test/normal.js'
  end

  it "runs file tests"
    view test/normal.js
    TestFile

    Expect g:test#last_command == 'mocha test/normal.js'
  end

  it "runs test suites"
    view test/normal.js
    TestSuite

    Expect g:test#last_command == 'mocha'
  end

  it "doesn't detect JavaScripts which are not in the test/ folder"
    view outside.js
    TestSuite

    Expect exists('g:test#last_command') == 0
  end

end
