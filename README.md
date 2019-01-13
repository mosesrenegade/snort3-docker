This is a very simple Dockfile for the new Snort3. Snort3 is in Beta, I suspect we will see an alpha build soon.

To use this particular Docker:

```
docker run --net host --it -e INTERFACE=eth0 mosesrenegade/snort3 -i eth0 -L log_pcap
```

A few notes here:
1. You need to have downloaded the snort3 subscriber ruleset here: 
http://www.snort.org/downloads

Roadmapped Items:
- Making Pulledport or automatic rule updates work
- Allowing for compilation with Shell
- Mounting a volume to store offline files and other items
- Integrations into output alerting systems.


