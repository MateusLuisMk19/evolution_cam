import 'package:evolution_cam/components/clickableCard.dart';
import 'package:flutter/material.dart';

class ShowChangesSlide extends StatefulWidget {
  final List<dynamic> imageUrls;
  final int timerSeconds;
  final bool reverseOrder;

  const ShowChangesSlide({
    Key? key,
    required this.imageUrls,
    this.timerSeconds = 2,
    this.reverseOrder = false,
  }) : super(key: key);

  @override
  State<ShowChangesSlide> createState() => _ShowChangesSlideState();
}

class _ShowChangesSlideState extends State<ShowChangesSlide> {
  late PageController _pageController;
  late List<dynamic> _orderedUrls;
  int _currentPage = 0;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _orderedUrls = widget.reverseOrder
        ? widget.imageUrls.reversed.toList()
        : List.from(widget.imageUrls);
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSlideshow();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startSlideshow() {
    if (!_isPlaying) {
      setState(() => _isPlaying = true);
    }
    _showNextImage();
  }

  void _stopSlideshow() {
    setState(() => _isPlaying = false);
  }

  void _showNextImage() {
    if (!_isPlaying) return;

    Future.delayed(Duration(seconds: widget.timerSeconds), () {
      if (!mounted || !_isPlaying) return;

      setState(() {
        if (_currentPage >= _orderedUrls.length - 1) {
          _currentPage = 0;
        } else {
          _currentPage++;
        }

        // Troca instantânea da página
        _pageController.jumpToPage(_currentPage);
      });

      _showNextImage();
    });
  }

  @override
  void didUpdateWidget(ShowChangesSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrls != oldWidget.imageUrls) {
      setState(() {
        _orderedUrls = widget.reverseOrder
            ? widget.imageUrls.reversed.toList()
            : List.from(widget.imageUrls);
        _currentPage = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: PageView.builder(
                controller: _pageController,
                // Desabilita a animação de deslize
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _orderedUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    _orderedUrls[index]['url'],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Controles de navegação
            Positioned(
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _isPlaying ? _stopSlideshow : _startSlideshow,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${_orderedUrls.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ImageGallery extends StatefulWidget {
  final List<dynamic> images;
  final Function(Map<String, dynamic>) onDelete;
  final bool selectAll;

  const ImageGallery({
    Key? key,
    required this.images,
    required this.onDelete,
    required this.selectAll,
  }) : super(key: key);

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  late List<bool> _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = List.generate(widget.images.length, (_) => true);
  }

  @override
  void didUpdateWidget(ImageGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectAll != oldWidget.selectAll) {
      setState(() {
        _isSelected =
            List.generate(widget.images.length, (_) => widget.selectAll);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reversedImgs = widget.images.reversed.toList();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: reversedImgs.length,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              MyClickable(
                onTap: () => Navigator.pushNamed(context, '/showimage',
                    arguments: reversedImgs[index]['url']),
                items: [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Excluir'),
                    onTap: () => widget.onDelete(reversedImgs[index]),
                  ),
                ],
                child: Image.network(
                  reversedImgs[index]['url'],
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  value: _isSelected[index],
                  onChanged: (value) {
                    setState(() {
                      _isSelected[index] = value!;
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    reversedImgs[index]['createdAt']
                        .toDate()
                        .toString()
                        .substring(0, 16),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  const ActionButtons({
    Key? key,
    required this.onGalleryTap,
    required this.onCameraTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 4,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: SizedBox(
          width: 170,
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 65,
                height: 60,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    elevation: 2,
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                  ),
                  iconSize: 30,
                  onPressed: onGalleryTap,
                  icon: Icon(Icons.add_photo_alternate),
                ),
              ),
              SizedBox(
                width: 65,
                height: 60,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    elevation: 2,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  iconSize: 30,
                  onPressed: onCameraTap,
                  icon: Icon(Icons.camera_alt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyCollectionView extends StatelessWidget {
  final String title;
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  const EmptyCollectionView({
    Key? key,
    required this.title,
    required this.onGalleryTap,
    required this.onCameraTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Coleção sem imagens.',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              ActionButtons(
                onGalleryTap: onGalleryTap,
                onCameraTap: onCameraTap,
              ),
            ],
          ),
        );
      }),
    );
  }
}
