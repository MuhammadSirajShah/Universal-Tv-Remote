import 'package:multicast_dns/multicast_dns.dart';

class DiscoveredTv {
  final String name;
  final String host;
  final int port;
  final String serviceType;

  const DiscoveredTv({
    required this.name,
    required this.host,
    required this.port,
    required this.serviceType,
  });
}

class TvDiscoveryService {
  Future<List<DiscoveredTv>> discoverTvs({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final client = MDnsClient();
    final discoveredTvs = <String, DiscoveredTv>{};

    try {
      await client.start();

      final serviceTypes = [
        '_http._tcp.local',
        '_googlecast._tcp.local',
      ];

      final endTime = DateTime.now().add(timeout);

      for (final serviceType in serviceTypes) {
        if (DateTime.now().isAfter(endTime)) {
          break;
        }

        await for (final PtrResourceRecord ptr
        in client.lookup<PtrResourceRecord>(
          ResourceRecordQuery.serverPointer(serviceType),
        )) {
          if (DateTime.now().isAfter(endTime)) {
            break;
          }

          await for (final SrvResourceRecord srv
          in client.lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(ptr.domainName),
          )) {
            if (DateTime.now().isAfter(endTime)) {
              break;
            }

            final host = srv.target.endsWith('.')
                ? srv.target.substring(0, srv.target.length - 1)
                : srv.target;

            final tv = DiscoveredTv(
              name: ptr.domainName,
              host: host,
              port: srv.port,
              serviceType: serviceType,
            );

            final key = '$host:${srv.port}';

            discoveredTvs[key] = tv;
          }
        }
      }

      return discoveredTvs.values.toList();
    } finally {
      client.stop();
    }
  }
}