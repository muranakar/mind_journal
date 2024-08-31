import 'package:flutter/material.dart';

class ReflectionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ダミーデータとして振り返りのリストを用意
    final reflections = [
      '今日はたくさんの新しいことを学んだ。',
      '昨日の振り返りをしようと思う。',
      '週末にリラックスできた。',
      // その他の振り返り内容
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('振り返りリスト'),
      ),
      body: ListView.builder(
        itemCount: reflections.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(reflections[index]),
            trailing: Icon(Icons.play_arrow),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReflectionScreen(
                    reflectionText: reflections[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ReflectionScreen extends StatefulWidget {
  final String reflectionText;

  ReflectionScreen({required this.reflectionText});

  @override
  _ReflectionScreenState createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isStopped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  void _stopAnimation() {
    setState(() {
      _isStopped = true;
      _controller.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('振り返り'),
        actions: [
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: _stopAnimation,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Align(
                alignment: Alignment.center,
                child: _isStopped
                    ? Text(
                        widget.reflectionText,
                        style: TextStyle(fontSize: 24),
                      )
                    : Text(
                        widget.reflectionText,
                        style: TextStyle(fontSize: 24),
                      ),
              ),
            ),
          ),
          Positioned(
            bottom: _fadeAnimation.value * 200, // 雲が上に浮かび上がる動き
            left: MediaQuery.of(context).size.width / 4,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Icon(
                Icons.cloud,
                size: 100,
                color: Colors.blue.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class FloatingTextScreen extends StatefulWidget {
  @override
  _FloatingTextScreenState createState() => _FloatingTextScreenState();
}

class _FloatingTextScreenState extends State<FloatingTextScreen> {
  final List<String> _texts = [
    '学びが大切',
    'リラックスが必要',
    '今日の反省',
    '新しい目標を立てよう',
    '少し休憩しよう',
    '頑張りすぎないように'
  ];
  int _currentIndex = 0;
  bool _isAnimating = true;

  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
  }

  void _startAnimationSequence() {
    Future.doWhile(() async {
      if (_currentIndex < _texts.length && _isAnimating) {
        setState(() {
          _currentIndex++;
        });
        await Future.delayed(Duration(seconds: 3));
        return true;
      } else {
        return false;
      }
    });
  }

  void _stopAnimation() {
    setState(() {
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Floating Text Animation'),
        actions: [
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: _stopAnimation,
          ),
        ],
      ),
      body: Stack(
        children: [
          for (int i = 0; i < _currentIndex; i++)
            Positioned(
              bottom: 0,
              left: (i % 2 == 0) ? 50.0 : 150.0, // バブルの位置を変化させる
              child: AnimatedBubble(
                text: _texts[i],
              ),
            ),
        ],
      ),
    );
  }
}

class AnimatedBubble extends StatefulWidget {
  final String text;

  AnimatedBubble({required this.text});

  @override
  _AnimatedBubbleState createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 20), // アニメーションをゆっくりさせる
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // MediaQueryを使って画面の高さを取得する処理をここに移動
    final double screenHeight = MediaQuery.of(context).size.height;
    _positionAnimation = Tween<double>(begin: 0, end: -screenHeight).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _positionAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.text,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
