module YouTube
  def self.extract_ref(s)
    return nil if s.nil?||s==''
    payload, query = s.split('?')
    v = query.split('&').find{|arg| arg[/^v=/]} unless query.nil?
    (v || payload)[/[a-zA-Z0-9\-_]+$/]
  end
end
