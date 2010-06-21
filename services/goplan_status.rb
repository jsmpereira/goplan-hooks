service :goplan_status do |payload, project_alias|
  repository = payload['repository']['name']
  message = payload['commits'][0]['message']
  commit_url = payload['commits'][0]['url']
  
  url = "/#{project_alias}/api/"
  
  status_text = "[#{repository}] #{message} - #{commit_url}"
  @access_token.put("#{url}statuses/update", {:format => 'json', :text => status_text})
end