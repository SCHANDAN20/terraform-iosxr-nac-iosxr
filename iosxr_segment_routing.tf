locals {
  device_segment_routing = flatten([
    for device in local.devices : [
      merge({
        device_name = device.name
      }, try(local.device_config[device.name].segment_routing, local.defaults.iosxr.configuration.segment_routing, {}))
    ]
    if try(local.device_config[device.name].segment_routing, null) != null || try(local.defaults.iosxr.configuration.segment_routing, null) != null
  ])
}

resource "iosxr_segment_routing" "segment_routing" {
  for_each                 = { for sr in local.device_segment_routing : sr.device_name => sr }
  device                   = each.value.device_name
  global_block_lower_bound = each.value.global_block_lower_bound
  global_block_upper_bound = each.value.global_block_upper_bound
  local_block_lower_bound  = each.value.local_block_lower_bound
  local_block_upper_bound  = each.value.local_block_upper_bound
  delete_mode              = try(each.value.delete_mode, null)
}
