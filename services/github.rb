service :github do |payload, project_alias|

  message = payload['commits'][0]['message']
  commit_url = payload['commits'][0]['url']
  
  url = "/#{project_alias}/api/"
  
  # Search for '[Closes #ticket_id]' in commit message
  ticket_id = message.scan(%r{Closes #+[0-9]+}).to_s.split("#")[1]  
  ticket = @access_token.put("#{url}tickets/update/#{ticket_id}.json", {'ticket[status]' => 2})
  
  puts ticket
  
  comment_text = "Closed: #{commit_url}"	
  comment =  @access_token.put("#{url}comments/create", {:format => 'json', 'comment[commentable_type]' => 'ticket', 'comment[commentable_cid]' => ticket_id, 'comment[text]' => comment_text})
  
  puts comment
end