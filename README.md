zimbra-scripts
==============

zimbra-size.sh
==============

Report zimbra mailbox size per folder for a specific user.

Sample output

```
[zimbra@zimbra ~]$ /tmp/zimbra-size.sh sakis@zimbra.gr
sakis@zimbra.gr's max mailbox size = 20480 MB, current mailbox size = 343.02 MB.

size (MB)  msgcount     unread folder
--------- --------- ---------- ----------------------------
        0         0          0 /Chats
        0         0          0 /Drafts
       12       221        221 /Inbox
       15      1001       1001 /Inbox/Tickets
      310      7158       7158 /Inbox/Syslog
        3        78         78 /Inbox/Wiki
        0         0          0 /Junk
        3        21          0 /Sent
...
```

quota-report.sh
===============

Reports top 50 mailboxes by disk usage (quota).

Edit script to fix sender and recepient emails.

Execute script via cronjob (user zimbra), daily at 23:30

    30 23 * * * /path/to/quota-report.sh

Sample output

```
From: admin@zimbra.gr
To: admin@zimbra.gr
Subject: Daily quota report for 2014-02-29

top 50 mailboxes by disk usage (quota)
--------------------------------------
5864 of 20480 MB takis@zimbra.gr
4310 of 20480 MB makis@zimbra.gr
3504 of 20480 MB soula@zimbra.gr
...
```

Notes
=====

Tested with Zimbra 8.0.x.

http://stsimb.irc.gr/2014/02/08/zimbra-mailbox-size-per-folder/
