service :github do |payload, project_alias|

  message = payload['commits'][0]['message']
  commit_url = payload['commits'][0]['url']
  
  url = "/#{project_alias}/api/"
  
  # Search for '[Closes #ticket_id]' and '[Relates to #ticket_id]' in commit message
  tickets = {}
  tickets[:to_close] = message.scan(%r{Closes #+[0-9]+})}
  tickets[:to_relate] = message.scan(%r{Relates to #+[0-9]+})}
  
  if !tickets[:to_close].empty?
    tickets[:to_close].each do |ticket|

      ticket_id = ticket.to_s.split("#")[1]
      @access_token.put("#{url}tickets/update/#{ticket_id}.json", {'ticket[status]' => 2})

      comment_text = "Closed: #{commit_url}"	

      @access_token.put("#{url}comments/create", {:format => 'json', 'comment[commentable_type]' => 'ticket', 'comment[commentable_cid]' => ticket_id, 'comment[text]' => comment_text})      
    end
  end
  
  if !tickets[:to_relate].empty?
    tickets[:to_relate].each do |ticket|

      ticket_id = ticket.to_s.split("#")[1]
      comment_text = "Relates to: #{commit_url}"	

      @access_token.put("#{url}comments/create", {:format => 'json', 'comment[commentable_type]' => 'ticket', 'comment[commentable_cid]' => ticket_id, 'comment[text]' => comment_text})
    end
  end

end