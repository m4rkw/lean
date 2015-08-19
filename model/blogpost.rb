
class BlogPost
    include Renderer

    attr_reader :uri
    attr_reader :subject
    attr_reader :date
    attr_reader :content

    def initialize(file)
        lines = File.open(file).each_line.to_a

        @date = Time.parse(lines[0].chomp)
        @subject = lines[1].chomp
        @published = lines[2].chomp == 'live'
        @uri = @subject.gsub(/[^a-zA-Z0-9\s]*/,'').downcase.gsub(/\s/,'-')

        content = ''

        for i in 4..lines.length
            if lines[i]
                content += lines[i]
            end
        end

        @content = ''
        
        parse_urls(content).split("\n\n").each do |p|
            @content += "<p>" + p + "</p>"
        end
    end

    def parse_urls(content)
        m = content.scan /https?:\/\/.*\b/

        for i in 0...m.length
            if m[i].match(/\.jpg\z/i) or m[i].match(/\.png\z/i)
                content.gsub!(m[i], '<img src="' + m[i] + '" />')
            else
                content.gsub!(m[i], '<a href="' + m[i] + '">' + m[i] + '</a>')
            end
        end

        return content
    end

    def render
        if @published
            partial('_blog_post', {
                'date' => @date,
                'subject' => @subject,
                'content' => @content,
                'uri' => @uri
            })
        end
    end
end
