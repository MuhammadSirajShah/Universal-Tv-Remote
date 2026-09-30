import 'package:flutter/material.dart';
import 'package:universal_tv_remote/services/wifi/tv_discovery_service.dart';

class WifiDiscoveryScreen extends StatefulWidget {
  const WifiDiscoveryScreen({super.key});

  @override
  State<WifiDiscoveryScreen> createState() => _WifiDiscoveryScreenState();
}

class _WifiDiscoveryScreenState extends State<WifiDiscoveryScreen> {
  final TvDiscoveryService _discoveryService = TvDiscoveryService();

  List<DiscoveredTv> _devices = [];

  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startSearching();
  }

  Future<void> _startSearching() async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _devices = [];
      _errorMessage = null;
    });

    try {
      final devices = await _discoveryService.discoverTvs();

      if (!mounted) return;

      setState(() {
        _devices = devices;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _errorMessage = 'Unable to search the network.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Your TV',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return _buildSearching();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_devices.isEmpty) {
      return _buildNoDevices();
    }

    return _buildDevices();
  }

  Widget _buildSearching() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_find_rounded,
              size: 55,
              color: Colors.indigo,
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Searching for TVs...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Searching your local Wi-Fi network for compatible devices.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 25),

          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildNoDevices() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.tv_off_rounded,
            size: 55,
            color: Colors.grey.shade500,
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'No TV Found',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Make sure your phone and Smart TV are connected to the same Wi-Fi network.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startSearching,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'Search Again',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 70,
            color: Colors.red.shade400,
          ),

          const SizedBox(height: 20),

          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            _errorMessage ?? 'Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 25),

          ElevatedButton.icon(
            onPressed: _startSearching,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildDevices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Devices',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '${_devices.length} device(s) found on your network.',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: ListView.separated(
            itemCount: _devices.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              final device = _devices[index];

              return _DeviceCard(
                device: device,
                onTap: () {
                  _showDeviceInfo(device);
                },
              );
            },
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _startSearching,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Search Again'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeviceInfo(DiscoveredTv device) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.tv_rounded,
                  size: 50,
                  color: Colors.indigo,
                ),

                const SizedBox(height: 15),

                Text(
                  device.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Host: ${device.host}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Port: ${device.port}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Service: ${device.serviceType}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'TV connection will be added in the next step.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Connect',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final DiscoveredTv device;
  final VoidCallback onTap;

  const _DeviceCard({
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.tv_rounded,
                color: Colors.indigo,
                size: 30,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${device.host}:${device.port}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}