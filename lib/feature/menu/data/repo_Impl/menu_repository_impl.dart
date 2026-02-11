import '../../domain/repository/menu_repository.dart';
import '../model/response/notification_response.dart';
import '../network/menu_network_request.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuNetworkRequest menuNetworkRequest;

  MenuRepositoryImpl(this.menuNetworkRequest);

  @override
  Future<NotificationResponse> getNotificationCount() {
    return menuNetworkRequest.getNotificationCount();
  }
}
