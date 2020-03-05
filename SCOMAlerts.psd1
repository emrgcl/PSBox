# Alert Table to Pull from SCOM
@{

    WMI = @('Operations Manager failed to run a WMI query','Operations Manager failed to run a WMI query for WMI events','Workflow Initialization: Failed to start a workflow that queries WMI','WMI is unhealthy')
    EventLog = @('Operations Manager Failed to access a Windows event log','Operations Manager Failed to Access the Windows Event Log','Processing Backlogged Events Taking a Long Time')
    Disk = @('Logical disk transfer (reads and writes) latency  is too high','Logical Disk Free Space is low')
    Memory = @('Microsoft.SystemCenter.Agent.MonitoringHost.PrivateBytesThreshold','Available Megabytes of Memory is too low')
    RunAsAccount = @('Run As Account Cannot Log On Locally', 'Run As Account Configuration Processing Error', 'Run As Account Could Not Log On','Run As Account does not have requested logon type','Unable to Verify Run As Account')
    Availability = @('Failed to Connect to Computer')


}
