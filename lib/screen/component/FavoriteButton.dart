
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mind_journal/model/diary.dart';

class FavoriteButton extends StatefulWidget {
  final Diary diary;
  final void Function(Diary) onToggleFavorite;
  final Color favoriteColor;
  final Color favoriteBorderColor;
  final double iconPadding;
  final double fontSize;

  const FavoriteButton({
    super.key,
    required this.diary,
    required this.onToggleFavorite,
    required this.favoriteColor,
    required this.favoriteBorderColor,
    required this.iconPadding,
    required this.fontSize,
  });

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> 
    with SingleTickerProviderStateMixin {  // アニメーション用のミックスイン追加
  
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    // アニメーションコントローラーの初期化
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),  // アニメーション時間
      vsync: this,
    );

    // 色のアニメーションを設定
    _colorAnimation = ColorTween(
      begin: widget.favoriteBorderColor,
      end: widget.favoriteColor,
    ).animate(_controller);

    // 初期状態の設定
    if (widget.diary.isFavorite) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // プロパティが変更された場合のアニメーション更新
    _colorAnimation = ColorTween(
      begin: widget.favoriteBorderColor,
      end: widget.favoriteColor,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();  // リソースの解放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IconButton(
          icon: Icon(
            widget.diary.isFavorite
                ? Icons.favorite
                : Icons.favorite_border,
            color: _colorAnimation.value,  // アニメーションで変化する色を使用
            size: widget.fontSize * 0.85,
          ),
          onPressed: () {
            if (widget.diary.isFavorite) {
              _controller.reverse();  // お気に入り解除時は逆アニメーション
            } else {
              _controller.forward();  // お気に入り追加時は通常アニメーション
            }
            widget.onToggleFavorite(widget.diary);
          },
          padding: EdgeInsets.all(widget.iconPadding),
          constraints: const BoxConstraints(),
        );
      },
    );
  }
}