The following table identifies the role of each port.

| Protocol |  Ports | Role |
| TCP/UDP | 53 | Domain Name System (DNS) |
| TCP/UDP | 88 | Kerberos authentication |
| TCP/UDP | 464 | Change/Set password |
| TCP/UDP | 389 | Lightweight Directory Access Protocol (LDAP) |
| UDP	| 123	| Network Time Protocol (NTP) |
| TCP	| 135	| Distributed Computing Environment / End Point Mapper (DCE / EPMAP) |
| TCP | 445 | Directory Services SMB file sharing |
| TCP | 636 | Lightweight Directory Access Protocol over TLS/SSL (LDAPS) |
| TCP | 3268 | Microsoft Global Catalog |
| TCP | 3269 | Microsoft Global Catalog over SSL |
| TCP | 5985 | WinRM 2.0 (Microsoft Windows Remote Management) |
| TCP | 9389 | Microsoft AD DS Web Services, PowerShell |
| TCP | 49152 - 65535 | Ephemeral ports for RPC (mandate for network ACLs) |
| TCP | 9389 | outbound traffic on TCP port for Multi-AZ |

