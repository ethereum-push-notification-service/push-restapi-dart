import 'package:blockies/blockies.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

import '../../../__lib.dart';

class SpaceSpeakerCard extends StatelessWidget {
  const SpaceSpeakerCard({
    required this.speaker,
  });

  final AdminPeer speaker;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pushColor),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(64),
                      child: Blockies(
                        seed: '${speaker.address}',
                        size: 4,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Column(
                    children: [
                      Text(
                        '${speaker.address}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Speaker',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                speaker.audio == true ? Icons.mic : Icons.mic_off,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpaceListernerCard extends StatelessWidget {
  const SpaceListernerCard({
    required this.listener,
  });

  final ListenerPeer listener;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pushColor),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(64),
                      child: Blockies(
                        seed: '${listener.address}',
                        size: 4,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${listener.address}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 12),
                  ),
                  Text(
                    'Listener',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          if (listener.handRaised == true)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.waving_hand,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SpaceHostCard extends StatelessWidget {
  const SpaceHostCard({
    required this.host,
  });

  final AdminPeer host;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pushColor),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(64),
                      child: Blockies(
                        seed: '${host.address}',
                        size: 4,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${host.address}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 12),
                  ),
                  Text(
                    'Host',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  host.audio == true ? Icons.mic : Icons.mic_off,
                ),
              ))
        ],
      ),
    );
  }
}
