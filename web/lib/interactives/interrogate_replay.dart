import 'dart:async';
import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class MessageItem {
  final String sender;
  final String text;
  final bool isMe;
  final bool isCode;

  const MessageItem({
    required this.sender,
    required this.text,
    required this.isMe,
    this.isCode = false,
  });
}

class InterrogateReplay extends StatefulWidget {
  const InterrogateReplay({super.key});

  @override
  State<InterrogateReplay> createState() => _InterrogateReplayState();
}

class _FocusNode extends FocusNode {}

class _InterrogateReplayState extends State<InterrogateReplay> {
  final List<MessageItem> _messages = [];
  bool _isTyping = false;
  final TextEditingController _controller = TextEditingController();

  final List<MessageItem> _initialHistory = [
    const MessageItem(
      sender: "System",
      text: "Connection established in Sandbox capsule #dintc-7729.",
      isMe: false,
    ),
    const MessageItem(
      sender: "Human",
      text: "/interrogate content/magenta-tv/spec.md --rule=no-external-libs",
      isMe: true,
    ),
  ];

  final List<String> _agentResponseLines = [
    "Starting code audit scan using prompt interrogate.txt...",
    "Scanning directories: lib/, content/magenta-tv/...",
    "Scanning package imports...",
    "[WARNING] Drift found in lib/recommendations.dart:18",
    "-> Code import found: 'third_party/untrusted/parser'",
    "-> This violates GEMINI.md guidelines (banned package!).",
    "[SUMMARY] Verification failed: 1 compliance error detected.",
    "Suggested action: Run /goldfish recommendations.dart 'Remove third_party/untrusted/parser and replace with standard dart:convert'"
  ];

  @override
  void initState() {
    super.initState();
    _messages.addAll(_initialHistory);
    // Start automated replay response
    _triggerResponse();
  }

  void _triggerResponse() {
    setState(() {
      _isTyping = true;
    });

    int lineIndex = 0;
    Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (lineIndex < _agentResponseLines.length) {
        setState(() {
          _messages.add(MessageItem(
            sender: "Interrogator-Agent",
            text: _agentResponseLines[lineIndex],
            isMe: false,
            isCode: _agentResponseLines[lineIndex].startsWith("[LOG]") || 
                    _agentResponseLines[lineIndex].startsWith("->") ||
                    _agentResponseLines[lineIndex].startsWith("Suggested action"),
          ));
        });
        lineIndex++;
      } else {
        timer.cancel();
        setState(() {
          _isTyping = false;
        });
      }
    });
  }

  void _handleSubmit(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(MessageItem(sender: "Human", text: text, isMe: true));
      _controller.clear();
      _isTyping = true;
    });

    // Mock quick reply
    Timer(const Duration(seconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(const MessageItem(
          sender: "Interrogator-Agent",
          text: "Stateless session closed. Run a new command on main specs.",
          isMe: false,
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.elevated, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SPEC COMPLIANCE AUDITOR",
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Interrogation Terminal & Logs",
                    style: AppTypography.subheading.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.accentPrimary),
                onPressed: () {
                  setState(() {
                    _messages.clear();
                    _messages.addAll(_initialHistory);
                  });
                  _triggerResponse();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Messages ListView
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.base,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _buildTypingIndicator();
                  }

                  final msg = _messages[index];
                  final isAgent = msg.sender == "Interrogator-Agent";
                  final isWarning = msg.text.contains("[WARNING]");

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment:
                          msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.sender,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: msg.isMe ? Colors.blueAccent : AppColors.accentPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: msg.isMe
                                ? Colors.blueAccent.withOpacity(0.1)
                                : isWarning
                                    ? Colors.red.withOpacity(0.1)
                                    : AppColors.elevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: msg.isMe
                                  ? Colors.blueAccent
                                  : isWarning
                                      ? Colors.red
                                      : AppColors.surface,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              fontFamily: (isAgent || msg.isCode) ? 'Courier' : null,
                              fontSize: 12,
                              color: isWarning ? Colors.redAccent : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Message input bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: _handleSubmit,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Enter agent terminal command (e.g. /interrogate)...",
                    fillColor: AppColors.elevated,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmit(_controller.text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentPrimary,
            ),
          ),
          SizedBox(width: 8),
          Text(
            "Agent is scanning rules compliance...",
            style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
