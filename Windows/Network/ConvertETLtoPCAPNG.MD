## One issue with Netsh is that it generated ETL files, which are not a file format that Wireshark supports. 

Luckily, someone from Microsoft has created a CLI tool called etl2pcapng which does the conversion from ETL to PCAP Utility that converts an .etl file containing a Windows network packet capture into .pcapng format.

To convert run the command line tool <br/>
**etl2pcapng.exe in.etl out.pcapng**
