require 'ftools'

class Apache
    
    def initialize(args)
        @dir = File.expand_path(args['service_dir'])
        @datadir = File.expand_path(args['data_dir'])
        @tempdir = File.expand_path(args['temp_dir'])
        File.makedirs(@tempdir)
    end

    def start(bp, args)
        loc = args['htdocs']
        callback = args['callback']
        port = ''
        File.open("#{@dir}/last.port").each { |line|
            port = line.chomp
        }
        @port = port

        File.copy("#{@dir}/httpd.conf", "#{@tempdir}/httpd.conf")

        File.open("#{@tempdir}/custom.conf", 'a') do |f1|
            f1.puts "DocumentRoot \"#{loc}\"\n"
            f1.puts "PidFile #{@tempdir}/apache2.pid\n"
            f1.puts "LockFile #{@tempdir}/accept.lock\n"
            f1.puts "Listen 127.0.0.1:#{port}\n"
            f1.puts "ErrorLog #{@tempdir}/error_log\n"
            f1.puts "<Directory \"#{loc}\">\n"
            f1.puts "    Options Indexes FollowSymLinks MultiViews\n"
            f1.puts "    AllowOverride All\n"
            f1.puts "</Directory>\n"
        end
        File.open("#{@tempdir}/httpd.conf", 'a') do |f1|
            f1.puts "include #{@tempdir}/custom.conf"
        end

        `httpd -D BPApache#{port} -d #{@tempdir} -f #{@tempdir}/httpd.conf`
        
        nport = port.to_f + 1
        nport = nport.to_s.split('.')[0]

        File.open("#{@dir}/last.port", 'w') do |f1|
            f1.puts "#{nport}\n"
        end

        url = "http://127.0.0.1:#{port}/"

        callback.invoke({
            'url' => url,
            'port' => port
        });
    end

    def stop(bp, args)
        callback = args['callback']
        pid = ''
        File.open("#{@tempdir}/apache2.pid").each { |line|
            pid = line.chomp
        }
        cmd = "kill #{pid}"
        `#{cmd}`
        `cd #{@tempdir} && rm *`

        callback.invoke({
            'done' => true
        });
    end

end


rubyCoreletDefinition = {
  'class' => "Apache",
  'name'  => "Apache",
  'major_version' => 0,
  'minor_version' => 0,
  'micro_version' => 4,
  'documentation' => 
    'Local Apache Server',

  'functions' =>
  [
    {
      'name' => 'start',
      'documentation' => "Start the Process",
      'arguments' =>
      [
         {
            'name' => 'htdocs',
            'type' => 'string',
            'required' => true,
            'documentation' => 'The file location (path) that you want to serve via Apache.'
          },
          {
            'name' => 'callback',
            'type' => 'callback',
            'required' => true,
            'documentation' => 'the callback to send a hello message to'
          }
      ]
    },
    {
      'name' => 'stop',
      'documentation' => "Stop the Process",
      'arguments' =>
      [
          {
            'name' => 'callback',
            'type' => 'callback',
            'required' => false,
            'documentation' => 'the callback to send a hello message to'
          }
      ]
    }
  ] 
}

