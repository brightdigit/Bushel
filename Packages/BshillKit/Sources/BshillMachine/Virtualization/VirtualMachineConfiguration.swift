
import Virtualization

struct VirtualMachineConfiguration : MachineConfiguration {
  let vzMachineConfiguration : VZVirtualMachineConfiguration
  let currentURL : URL
}
