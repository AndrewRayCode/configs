source test/helpers.vim

function! test#shell(cmd, ...) abort
  let g:test#last_command = substitute(a:cmd, ' --doctest-tests', '', '')
endfunction

describe "Nose"

  before
    cd test/fixtures/nose
  end

  after
    call Teardown()
    cd -
  end

  it "runs nearest tests"
    view +2 test_class.py
    TestNearest

    Expect g:test#last_command == 'nosetests test_class.py:TestNumbers.test_numbers'

    view +1 test_class.py
    TestNearest

    Expect g:test#last_command == 'nosetests test_class.py:TestNumbers'

    view +1 test_method.py
    TestNearest

    Expect g:test#last_command == 'nosetests test_method.py:test_numbers'
  end

  it "runs file test if nearest test couldn't be found"
    view +1 test_method.py
    normal O
    TestNearest

    Expect g:test#last_command == 'nosetests test_method.py'
  end

  it "runs file tests"
    view test_class.py
    TestFile

    Expect g:test#last_command == 'nosetests test_class.py'
  end

  it "runs test suites"
    view test_class.py
    TestSuite

    Expect g:test#last_command == 'nosetests'
  end

end
