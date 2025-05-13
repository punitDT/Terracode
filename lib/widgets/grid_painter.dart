// Custom painter for rendering the game grid
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../models/grid.dart';

class GridPainter extends CustomPainter {
  final Grid grid;
  final bool showGridLines;

  GridPainter({required this.grid, this.showGridLines = true});

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / grid.columns;
    final cellHeight = size.height / grid.rows;

    // Paint for grid lines
    final gridPaint =
        Paint()
          ..color = Colors.black12
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    // Paint for cells
    final cellPaint = Paint()..style = PaintingStyle.fill;

    // Draw cells
    for (int y = 0; y < grid.rows; y++) {
      for (int x = 0; x < grid.columns; x++) {
        final cell = grid.cells[y][x];
        final rect = Rect.fromLTWH(
          x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        );

        // Draw cell based on its type and state
        _drawCell(canvas, rect, cell, cellPaint);

        // Draw grid lines if enabled
        if (showGridLines) {
          canvas.drawRect(rect, gridPaint);
        }
      }
    }
  }

  void _drawCell(Canvas canvas, Rect rect, Cell cell, Paint paint) {
    // Draw background for all cells
    paint.color = Colors.white;
    canvas.drawRect(rect, paint);

    // Draw cell based on its type
    switch (cell.type) {
      case CellType.wall:
        paint.color = Colors.black87;
        canvas.drawRect(rect, paint);
        break;

      case CellType.source:
        // Draw source cell with full color
        if (cell.color != null) {
          paint.color = cell.color!;
          canvas.drawRect(rect, paint);

          // Draw a source indicator (circle)
          final sourcePaint =
              Paint()
                ..color = Colors.white.withOpacity(0.5)
                ..style = PaintingStyle.fill;

          final center = rect.center;
          final radius = rect.width * 0.3;
          canvas.drawCircle(center, radius, sourcePaint);
        }
        break;

      case CellType.speedBoost:
        // Draw speed boost cell
        paint.color = Colors.yellowAccent;
        canvas.drawRect(rect, paint);

        // Draw a speed indicator
        final center = rect.center;
        final path = Path();
        final arrowSize = rect.width * 0.3;

        path.moveTo(center.dx - arrowSize, center.dy);
        path.lineTo(center.dx + arrowSize, center.dy);
        path.lineTo(center.dx, center.dy - arrowSize);
        path.close();

        final arrowPaint =
            Paint()
              ..color = Colors.black54
              ..style = PaintingStyle.fill;

        canvas.drawPath(path, arrowPaint);
        break;

      case CellType.absorption:
        // Draw absorption cell
        paint.color = Colors.purpleAccent;
        canvas.drawRect(rect, paint);

        // Draw an absorption indicator (spiral or whirlpool)
        final center = rect.center;
        final radius = rect.width * 0.3;
        final spiralPaint =
            Paint()
              ..color = Colors.white.withOpacity(0.7)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0;

        final path = Path();
        for (double i = 0; i < 3; i += 0.05) {
          final r = radius * (1 - i / 3);
          final x = center.dx + r * math.cos(i * 10);
          final y = center.dy + r * math.sin(i * 10);

          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }

        canvas.drawPath(path, spiralPaint);
        break;

      case CellType.empty:
        // Draw occupied cells with color and progress
        if (cell.isOccupied && cell.color != null) {
          // Adjust opacity based on spread progress
          final opacity = 0.3 + (cell.spreadProgress * 0.7);
          paint.color = cell.color!.withOpacity(opacity);
          canvas.drawRect(rect, paint);
        } else if (cell.isMixing) {
          // Draw mixing indicator
          paint.color = Colors.grey.withOpacity(0.5);
          canvas.drawRect(rect, paint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return true; // Always repaint for animation
  }
}
