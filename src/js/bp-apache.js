(function() {
    var Dom = YAHOO.util.Dom,
        Event = YAHOO.util.Event;
    
    BrowserPlus.init(function(res) {
        if (res.success) {
            BrowserPlus.require({
                services: [
                    {
                        service: 'Apache',
                        version: '0',
                        minversion: '0.0.4'
                    }
                ]
            }, function(r) {
                if (r.success) {
                    Event.on('start', 'click', function(e) {
                        Dom.get('stop').disabled = false;
                        Dom.get('start').disabled = true;

                        BrowserPlus.Apache.start({
                            htdocs: '/tmp/dav-root/',
                            callback: function(r) {
                                alert('Apache service started: ' + r.url);
                            }
                        }, function() { console.log(arguments); });
                    });
                    Event.on('stop', 'click', function(e) {
                        Dom.get('start').disabled = false;
                        Dom.get('stop').disabled = true;

                        BrowserPlus.Apache.stop({
                            callback: function() {
                                console.log(arguments);
                                alert('Apache intance stopped..');
                            }
                        }, function() { console.log(arguments); });
                    });
                } else {
                    alert('BP-AddressBook failed to load..');
                }
            });
        } else {
            alert('Browser Plus failed to load...');
        }
    });

})();
