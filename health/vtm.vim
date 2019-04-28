" @Author: voldikss
" @Date: 2019-04-28 13:32:21
" @Last Modified by: voldikss
" @Last Modified time: 2019-04-28 13:32:21

function! s:check_job() abort
    if exists(*jobstart) || exists('*job_start')
        call health#report_ok('+job is available to execute python command')
    else
        call health#report_error('+job feature is required to execute python command')
    endif
endfunction

function! s:check_floating_window() abort
    if !has('nvim')
        call health#report_warning('Floating window is currently not available in Vim, will use preview instead')
        return 
    endif

    if exists('*nvim_open_win')
        call health#report_ok('Floating window is available to display translation')
    else
        call health#report_warning('Floating window is not available, will use preview instead')
    endif
endfunction

function! s:check_python() abort
    if executable('python')
        call health#report_ok('Python is installed')
    else
        call health#report_error('Python is required but not installed or executable')
    endif
endfunction

function! s:check_vim_version() abort
    if has('nvim')
        return 
    endif

    if v:version < 800
        call health#report_error(
            \ 'Your vim is too old: ' . v:version . ' and not supported by the plugin'
            \ 'Please install Vim 8.0 or later')
    endif
endfunction

function! health#vtm#check() abort
    call s:check_job()
    call s:check_floating_window()
    call s:check_python()
    call s:check_vim_version()
endfunction
