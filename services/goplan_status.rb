service :goplan_status do |payload, project_alias|
  repository = payload['repository']['name']
  commit_url = payload['commits'][0]['url']
  tiny_url = shorten_url(commit_url)
  
  url = "/#{project_alias}/api/"
  
  status_text = "Commit: [#{repository}] #{tiny_url}"
  @access_token.put("#{url}statuses/update", {:format => 'json', :text => status_text})
end