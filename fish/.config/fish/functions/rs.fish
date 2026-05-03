function rs --wraps='heroku local -f Procfile.dev' --description 'Run rails local server'

    heroku local -f Procfile.dev $argv

end
