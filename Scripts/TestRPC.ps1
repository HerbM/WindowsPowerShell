
<#PSScriptInfo
.VERSION 1.0
.GUID 2fda37e6-9d6d-4cff-b0ae-9f924ddf4afb
.AUTHOR Ryan Ries
.COMPANYNAME
.COPYRIGHT
.TAGS
.LICENSEURI
.PROJECTURI
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
#>
# Author: Ryan Ries [MSFT]
# Origianl date: 15 Feb. 2014
#Requires -Version 3


<#
.DESCRIPTION
  This script tests TCP network connectivity to not just the RPC Endpoint Mapper on port 135, but it also checks TCP network connectivity to each of the registered endpoints returned by querying the EPM.  I wrote this because many firewall teams have a difficult time with RPC, and they will end up allowing the Endpoint Mapper on port 135, but forget to also allow the ephemeral ports through the firewall.  This script uses localhost by default, but obviously you can specify a remote machine name or IP address to test a server across the network.  The script works by P/Invoking functions exported from rpcrt4.dll to get an enumeration of registered endpoints from the endpoint mapper, so it's not just a wrapper around portqry.exe.
#>
Function Test-RPC {
  [CmdletBinding(SupportsShouldProcess = $True)]
  Param(
    [Parameter(ValueFromPipeline = $True)][String[]]$ComputerName = 'localhost',
    [Switch]$ShowPorts = $False
  )
  BEGIN {
    Set-StrictMode -Version Latest
    # $RpcClass = 'Rpc'
    $PInvokeCode = @"
      using System;
      using System.Collections.Generic;
      using System.Runtime.InteropServices;

      public class Rpc {
        // I found this crud in RpcDce.h
        [DllImport("Rpcrt4.dll", CharSet = CharSet.Auto)]
        public static extern int RpcBindingFromStringBinding(string StringBinding, out IntPtr Binding);
        [DllImport("Rpcrt4.dll")]
        public static extern int RpcBindingFree(ref IntPtr Binding);
        [DllImport("Rpcrt4.dll", CharSet = CharSet.Auto)]
        public static extern int RpcMgmtEpEltInqBegin(IntPtr EpBinding,
                                                      int InquiryType, // 0x00000000 = RPC_C_EP_ALL_ELTS
                                                      int IfId,
                                                      int VersOption,
                                                      string ObjectUuid,
                                                      out IntPtr InquiryContext);
        [DllImport("Rpcrt4.dll", CharSet = CharSet.Auto)]
        public static extern int RpcMgmtEpEltInqNext(IntPtr InquiryContext,
                                                        out RPC_IF_ID IfId,
                                                        out IntPtr Binding,
                                                        out Guid ObjectUuid,
                                                        out IntPtr Annotation);
        [DllImport("Rpcrt4.dll", CharSet = CharSet.Auto)]
        public static extern int RpcBindingToStringBinding(IntPtr Binding, out IntPtr StringBinding);
        public struct RPC_IF_ID {
          public Guid Uuid;
          public ushort VersMajor;
          public ushort VersMinor;
        }
        public static List<int> QueryEPM(string host) {
          # List<int> ports = new List<int>();
          List<string> ports = new List<string>();
          int retCode = 0; // RPC_S_OK
          IntPtr bindingHandle = IntPtr.Zero;
          IntPtr inquiryContext = IntPtr.Zero;
          IntPtr elementBindingHandle = IntPtr.Zero;
          RPC_IF_ID elementIfId;
          Guid elementUuid;
          IntPtr elementAnnotation;
          try {
            retCode = RpcBindingFromStringBinding("ncacn_ip_tcp:" + host, out bindingHandle);
            if (retCode != 0)
              throw new Exception("RpcBindingFromStringBinding: " + retCode);
            retCode = RpcMgmtEpEltInqBegin(bindingHandle, 0, 0, 0, string.Empty, out inquiryContext);
            if (retCode != 0)
              throw new Exception("RpcMgmtEpEltInqBegin: " + retCode);
            do {
              IntPtr bindString = IntPtr.Zero;
              retCode = RpcMgmtEpEltInqNext (inquiryContext, out elementIfId, out elementBindingHandle, out elementUuid, out elementAnnotation);
              if (retCode != 0)
                if (retCode == 1772) break;
              retCode = RpcBindingToStringBinding(elementBindingHandle, out bindString);
              if (retCode != 0)
                throw new Exception("RpcBindingToStringBinding: " + retCode);
              string s = Marshal.PtrToStringAuto(bindString).Trim().ToLower();
              if(s.StartsWith("ncacn_ip_tcp:"))
                ports.Add(s);
                // ports.Add(int.Parse(s.Split('[')[1].Split(']')[0]));
              RpcBindingFree(ref elementBindingHandle);
            } while (retCode != 1772); // RPC_X_NO_MORE_ENTRIES
          } catch (Exception ex) {
            Console.WriteLine(ex);
            return ports;
          } finally {
            RpcBindingFree(ref bindingHandle);
          }
          return ports;
        }
      }
"@
    # Try {
      Add-Type $PInvokeCode -ea Ignore
    # } Catch {
      Write-Verbose "Unable to Add-Type $PInvokeCode for RPC Mapping"
    #}
  }  <# END #>
  PROCESS {
    ForEach ($Computer In $ComputerName) {
      If ($PSCmdlet.ShouldProcess($Computer)) {
        [Bool]$EPMOpen = $False
        $Socket = New-Object Net.Sockets.TcpClient
        Try {
          $Socket.Connect($Computer, 135)
          If ($Socket.Connected) {
            $EPMOpen = $True
          }
          $Socket.Close()
        } Catch {
          $Socket.Dispose()
        }
        If ($EPMOpen) {
          $RPCPorts = [Rpc]::QueryEPM($Computer)
          [Bool]$AllPortsOpen = $True
          Foreach ($Port In $RPCPorts) {
            $Socket = New-Object Net.Sockets.TcpClient
            Try {
              $Socket.Connect($Computer, $Port)
              If (!$Socket.Connected) {
                $AllPortsOpen = $False
              }
              $Socket.Close()
            } Catch {
              $AllPortsOpen = $False
              $Socket.Dispose()
            }
            If ($ShowPorts) {
              $Port
            # [PSObject]@{
            #   'ComputerName' = $Computer;
            #   'RPCPortsInUse' = $RPCPorts;
            #   'AllRPCPortsOpen' = $AllPortsOpen
            # }
            }
          }
          If ($ShowPorts) {
          } Else {
            [PSObject]@{
              'ComputerName' = $Computer;
              'EndPointMapperOpen' = $EPMOpen;
              'RPCPortsInUse' = $RPCPorts;
              'AllRPCPortsOpen' = $AllPortsOpen
            }
          }
        } Else {
          [PSObject]@{'ComputerName' = $Computer; 'EndPointMapperOpen' = $EPMOpen }
        }
      }
    }
  }
  END {  }
}