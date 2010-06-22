service :goplan_status do |payload, project_alias|
  repository = payload['repository']['name']
  commit_url = payload['commits'][0]['url']
  tiny_url = shorten_url(commit_url)
  message = payload['commits'][0]['message']
  
  url = "/#{project_alias}/api/"
  
  ticket = message.scan(%r{Closes #+[0-9]+})
  
  status_text = "[#{repository}] #{tiny_url} #{ticket}"
  @access_token.put("#{url}statuses/update", {:format => 'json', :text => status_text})
end