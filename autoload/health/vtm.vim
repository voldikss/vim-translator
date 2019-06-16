" @Author: voldikss
" @Date: 2019-04-28 13:32:21
" @Last Modified by: voldikss
" @Last Modified time: 2019-04-28 13:32:21

function! health#vtm#check_floating_window() abort
    if !has('nvim') || !exists('*nvim_open_win')
        return v:false
    else
        try
            let test_win = nvim_open_win(bufnr('%'), v:false, {
                \ 'relative': 'editor',
                \ 'row': 0,
                \ 'col': 0,
                \ 'width': 1,
                \ 'height': 1,
                \ })
            call nvim_win_close(test_win, v:true)
        catch /^Vim\%((\a\+)\)\=:E119/	
            return v:false
        endtry
    endif
    return v:true
endfunction

function! s:check_job() abort
    if exists('*jobstart') || exists('*job_start')
        call health#report_ok('Async check passed')
    else
        call health#report_error('+job feature is required to execute network request')
    endif
endfunction

function! s:check_floating_window() abort
    if health#vtm#check_floating_window()
        call health#report_ok('Floating window check passed')
    else
        call health#report_warning('Floating window check failed, use preview instead')
    endif
endfunction

function! s:check_python() abort
    if executable('python')
        call health#report_ok('Python check passed')
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
            \ 'Your vim is too old: ' . v:version . ' and not supported by the plugin' .
            \ 'Please install Vim 8.0 or later')
    endif
endfunction

function! health#vtm#check() abort
    call s:check_job()
    call s:check_floating_window()
    call s:check_python()
    call s:check_vim_version()
endfunction
