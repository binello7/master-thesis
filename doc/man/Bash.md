# Commands
* ``man command``: see the manual for _command_
* ``which command``: shows the path for _command_
* ``$(command)``: result of _command_

* ``chmod +x filename.ext``: makes _filename.ext_ an executable file

* ``touch filename``: creates an emtpy file named _filename_
* ``grep``: searches a file or folder for the given word or strings
      - ``grep 'word' filename``
      - ``grep 'word' file1 file2 file3``
      - ``grep 'string1 string2'  filename``
      - ``grep -r "string" /folder/`` recursively, searches for _string_ in all files under _folder_
      - ``grep -i "sTrINg" filename`` looks for _sTrINg_ into _filename_ ignoring word case
* cat:
* load:
* do
* echo
* ``ln -s``: create a _s_ymbolic link
* ``info`` _ProgramName_: informations for the specified program are shown
* done
* nproc: returns the number of processors
* pause(): forces the system to pause by the given amount of seconds
* tar: uncompress an archive (many possible options)
* wait: 
* ``ssh username@hostname``: connects to _username@hostname_ via ssh
* ``nohup command``: executes _command_ in nohup mode. Closing connection (terminal window, ssh connection) doesn't stop the process. Output goes to the file nohup.out
* ``scp``: copy files or folders between different hosts
      - ``scp your_username@remotehost:filename.ext /some/local/directory``: copy from remote host to local host
      - ``scp filename.ext your_username@remotehost:/some/remote/directory``: copy from local host to remote host 

# Utility
* ``top``: provides a dynamic real-time view of the running system (kind of system monitor)
* ``nano filename``: opens _filename_ with _nano_ the command-line text editor
* ``xset dpms force off``: turns off the screen
