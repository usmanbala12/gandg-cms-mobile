abstract class MediaRepository {
  Future<void> uploadMediaQueueHandler(String mediaId);
  Future<List<Map<String, dynamic>>> getPendingMediaForUpload(
    String projectId, {
    int limit = 10,
  });
  Future<int> totalMediaSizeForProject(String projectId);
  Future<void> deleteMedia(String mediaId);
}
