import '../../data/model/response/notification_response.dart';
import '../repository/menu_repository.dart';

class MenuUseCase {
  final MenuRepository menuRepository;

  MenuUseCase(this.menuRepository);

  Future<NotificationResponse> fetchNotificationCount() {
    return menuRepository.getNotificationCount();
  }
}
