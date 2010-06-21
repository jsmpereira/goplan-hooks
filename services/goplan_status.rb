service :goplan_status do |payload, project_alias|
  repository = payload['repository']['name']
  message = payload['commits'][0]['message'][30]
  commit_url = payload['commits'][0]['url']
  tiny_url = shorten_url(commit_url)
  
  url = "/#{project_alias}/api/"
  
  status_text = "[#{repository}] #{message} - #{tiny_url}"
  @access_token.put("#{url}statuses/update", {:format => 'json', :text => status_text})
end