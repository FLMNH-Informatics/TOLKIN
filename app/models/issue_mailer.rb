class IssueMailer < ActionMailer::Base
  def issue_mail(issue)
    from       ADMIN_EMAIL_FROM
    recipients ADMIN_RECIPIENTS
    subject    "TOLKIN ADMIN: Feedback Issue ##{issue.id.to_s}"
    body       :issue => issue
  end

  #Genbank sequence submission changes - START
  def sendmail(sender, title, sent_at = Time.now)
      @from = sender
      @subject = "Test submission"
      @recipients = "gb-sub@ncbi.nlm.nih.gov"
      @sent_on = sent_at
	    @body[:title] = title
      @file_name = "#{RAILS_ROOT}/public/files/FastaFile.sqn"
      attachment :content_type => "application/sqn",
         :body => File.read(@file_name),
         :filename => "FastaFile.sqn"
      
      #delete_attachment_file
   end

  def delete_attachment_file
    File.delete(@file_name)
  end
  #Genbank sequence submission changes - END

end