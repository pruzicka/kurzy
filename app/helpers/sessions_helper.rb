module SessionsHelper
  def browser_name(user_agent)
    ua = user_agent.to_s
    case ua
    when /Edg/i then "Edge"
    when /Chrome/i then "Chrome"
    when /Firefox/i then "Firefox"
    when /Safari/i then "Safari"
    when /Opera|OPR/i then "Opera"
    else "Neznámý prohlížeč"
    end
  end

  def os_name(user_agent)
    ua = user_agent.to_s
    case ua
    when /Windows/i then "Windows"
    when /Macintosh|Mac OS/i then "macOS"
    when /Linux/i then "Linux"
    when /iPhone|iPad/i then "iOS"
    when /Android/i then "Android"
    else "Neznámý OS"
    end
  end
end
