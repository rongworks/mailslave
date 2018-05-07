class LogViewController < ApplicationController
  def index
    skip_policy_scope
    lines = params[:lines]
    log_strings = `tail -n #{lines} log/log_stash_development.log`.split("\n")
    @logs = log_strings.collect {|l| JSON.parse(l)}
  end
end
