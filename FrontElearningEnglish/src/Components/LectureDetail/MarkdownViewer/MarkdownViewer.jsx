import React from "react";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { FaDownload, FaExternalLinkAlt, FaEye } from "react-icons/fa";
import "./MarkdownViewer.css";

function MarkdownViewer({ lecture }) {
    const title = lecture?.title || lecture?.Title || "";
    const markdownContent = lecture?.markdownContent || lecture?.MarkdownContent || "";
    const type = lecture?.type || lecture?.Type;
    const mediaUrl = lecture?.mediaUrl || lecture?.MediaUrl;

    return (
        <div className="markdown-viewer">
            <header className="lecture-header">
                <h1 className="lecture-title">{title}</h1>
            </header>
            <div className="lecture-content">
                {/* Markdown Content (Description) */}
                {markdownContent && markdownContent.trim().length > 0 ? (
                    <div className="markdown-content mb-4">
                        <ReactMarkdown remarkPlugins={[remarkGfm]}>
                            {markdownContent}
                        </ReactMarkdown>
                    </div>
                ) : (
                    // Only show "no content" if there is also no media
                    (!mediaUrl) && (
                        <div className="no-content-message">
                            <p>Nội dung bài giảng đang được cập nhật...</p>
                        </div>
                    )
                )}

                {/* Document Viewer */}
                {type === 2 && mediaUrl && (
                    <div className="document-viewer-container">
                        <div className="document-toolbar d-flex align-items-center gap-4 mb-3 p-3 bg-light border rounded">
                            <div className="d-flex align-items-center text-primary">
                                <FaEye className="me-2" />
                                <span className="fw-bold">Preview</span>
                            </div>
                            <a href={mediaUrl} target="_blank" rel="noopener noreferrer" download className="text-decoration-none text-secondary d-flex align-items-center" style={{ cursor: 'pointer' }}>
                                <FaDownload className="me-2" />
                                <span>Download Document</span>
                            </a>
                            <a href={`https://docs.google.com/viewer?url=${encodeURIComponent(mediaUrl)}`} target="_blank" rel="noopener noreferrer" className="text-decoration-none text-secondary d-flex align-items-center">
                                <FaExternalLinkAlt className="me-2" />
                                <span>Open in new tab</span>
                            </a>
                        </div>
                        <div className="document-frame-wrapper border rounded overflow-hidden shadow-sm" style={{ height: '800px', background: '#f8f9fa' }}>
                            <iframe
                                src={`https://docs.google.com/viewer?url=${encodeURIComponent(mediaUrl)}&embedded=true`}
                                style={{ width: '100%', height: '100%', border: 'none' }}
                                title="Document Viewer"
                                allowFullScreen
                            />
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}

MarkdownViewer.displayName = "MarkdownViewer";

export default MarkdownViewer;

