

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: HoverDock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}


class HoverDock extends StatefulWidget {
  const HoverDock({super.key, required this.items});

  final List<IconData> items;

  @override
  State<HoverDock> createState() => _HoverDockState();
}

class _HoverDockState extends State<HoverDock> {
  double _dockScale = 1.0;
  bool _isDragging = false;
  int? _hoveredIndex; 

  void _onEnter(int index) {
    if (!_isDragging) {
      setState(() {
        _dockScale = 1.1;
        _hoveredIndex = index; 
      });
    }
  }

  void _onExit(PointerEvent details) {
    if (!_isDragging) {
      setState(() {
        _dockScale = 1.0;
        _hoveredIndex = null; 
      });
    }
  }

  void _onDragStarted() {
    setState(() {
      _dockScale = 1.2;
      _isDragging = true;
    });
  }

  void _onDragEnd() {
    setState(() {
      _dockScale = 1.0;
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: _onExit, 
      child: AnimatedScale(
        scale: _dockScale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Dock(
          items: widget.items,
          isDragging: _isDragging,
          onDragStarted: _onDragStarted,
          onDragEnd: _onDragEnd,
          hoveredIndex: _hoveredIndex,
          onEnter: _onEnter,
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.isDragging,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.hoveredIndex,
    required this.onEnter,
  });

  final List<IconData> items;
  final bool isDragging;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnd;
  final int? hoveredIndex;
  final void Function(int index) onEnter;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items = widget.items.toList();
  int? _draggingIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          _items.length,
          (index) {
            return _buildDraggableIcon(index);
          },
        ),
      ),
    );
  }

  Widget _buildDraggableIcon(int index) {
    return Draggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: HoverIcon(icon: _items[index]),
      ),
      onDragStarted: widget.onDragStarted,
      onDragEnd: (_) {
        widget.onDragEnd();
        setState(() {
          _draggingIndex = null;
        });
      },
      childWhenDragging: const SizedBox.shrink(),
      child: DragTarget<int>(
        onAccept: (draggedIndex) {
          setState(() {
            final draggedItem = _items.removeAt(draggedIndex);
            _items.insert(index, draggedItem);
            _draggingIndex = null;
          });
        },
        onWillAccept: (draggedIndex) {
          setState(() {
            _draggingIndex = index;
          });
          return draggedIndex != index;
        },
        builder: (context, candidateData, rejectedData) {
          final isCurrentDragged = _draggingIndex == index;
          final horizontalMargin = widget.isDragging
              ? (isCurrentDragged ? 16.0 : 2.0)
              : 8.0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            child: HoverIcon(
              icon: _items[index],
              onEnter: () => widget.onEnter(index),
            ),
          );
        },
      ),
    );
  }
}

class HoverIcon extends StatefulWidget {
  const HoverIcon({super.key, required this.icon, this.onEnter});

  final IconData icon;
  final void Function()? onEnter;

  @override
  State<HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<HoverIcon> {
  double _scale = 1.0;

  void _onEnter(PointerEvent details) {
    setState(() {
      _scale = 1.2;
    });
    widget.onEnter?.call();
  }

  void _onExit(PointerEvent details) {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          constraints: const BoxConstraints(minWidth: 48),
          height: 48,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.primaries[widget.icon.hashCode % Colors.primaries.length],
          ),
          child: Center(
            child: Icon(widget.icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
