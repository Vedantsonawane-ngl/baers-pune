// Single place to change the backend URL.
// Android emulator: use 10.0.2.2
// Physical device on LAN: use your machine's actual IP, e.g. 192.168.1.10
// Windows desktop / Chrome: use 127.0.0.1
class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
}
