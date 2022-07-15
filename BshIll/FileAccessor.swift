



protocol FileAccessor {
  func getData () -> Data?
  func writeTo(_ url: URL) throws
  
}
