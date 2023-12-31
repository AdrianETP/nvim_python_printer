M = {}

local function open_result_buffer()
    local buflist = vim.api.nvim_command_output("ls")
    local buffer = buflist:find("python result")
    if buffer ~= nil then
        vim.cmd("bdelete! python\\ result")
    end
    vim.cmd('vnew')
    vim.cmd("vertical resize 50")
    vim.cmd('file python result')
    local bufnr = vim.fn.bufnr("python\\ result")
    return bufnr
end
function is_tmux()
    local tmux_var = vim.fn.getenv("TMUX")
    if tmux_var and type(tmux_var) == "string" and #tmux_var > 0 then
        return true
    else
        return false
    end
end

M.setup = function(params)
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        pattern  = { "*.py" },
        callback = function()
            if is_tmux() then
                vim.fn.system('tmux display-popup -E "python3 ' .. vim.fn.expand("%:p") .. '| less -R"')
            else
                local bufnr = open_result_buffer()
                vim.fn.jobstart({ "python3", vim.fn.expand("#:p") }, {
                    stdout_buffered = false,
                    on_stdout = function(_, data)
                        if data then
                            vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, data)
                        end
                    end
                })
            end
        end
    })
end

return M
