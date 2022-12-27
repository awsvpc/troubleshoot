## One issue with Netsh is that it generated ETL files, which are not a file format that Wireshark supports. Luckily, someone from Microsoft has created a CLI tool called etl2pcapng which does the conversion from ETL to PCAP, which can be found here –> microsoft/etl2pcapng: Utility that converts an .etl file containing a Windows network packet capture into .pcapng format. (github.com)
Then by running the command line tool
**etl2pcapng.exe in.etl out.pcapng
**
