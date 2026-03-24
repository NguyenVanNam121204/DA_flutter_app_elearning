import React, { useState, useEffect, useRef, useCallback, useMemo } from "react";
import { Modal, Button, Form, Row, Col, Alert } from "react-bootstrap";
import { FaBook, FaMarkdown, FaBold, FaItalic, FaHeading, FaListUl, FaCode, FaVideo, FaFileAlt, FaSitemap, FaArrowRight, FaTimes, FaCheckCircle, FaFileUpload } from "react-icons/fa";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { lectureService } from "../../../Services/lectureService";
import { fileService } from "../../../Services/fileService";
import FileUpload from "../../Common/FileUpload/FileUpload";
import ConfirmModal from "../../Common/ConfirmModal/ConfirmModal";
import { useEnums } from "../../../Context/EnumContext";
import "./CreateLectureModal.css";

const LECTURE_MEDIA_BUCKET = "lectures";

export default function CreateLectureModal({ show, onClose, onSuccess, moduleId, moduleName, lectureToUpdate, isAdmin = false }) {
  const isEditMode = !!lectureToUpdate && !lectureToUpdate._isChildCreation;
  const isChildCreation = !!lectureToUpdate?._isChildCreation;
  const textAreaRef = useRef(null);
  const { lectureTypes } = useEnums();

  // Get lecture types from API, fallback to default if not loaded
  const LECTURE_TYPES = lectureTypes && lectureTypes.length > 0
    ? lectureTypes.map(type => ({ value: type.value, label: type.name }))
    : [
      { value: 1, label: "Content" },
      { value: 2, label: "Document" },
      { value: 3, label: "Video" }
    ];

  // Form state
  const [title, setTitle] = useState("");
  const [orderIndex, setOrderIndex] = useState(0);
  const [numberingLabel, setNumberingLabel] = useState("");
  const [lectureType, setLectureType] = useState(1); // Default: Content
  const [markdownContent, setMarkdownContent] = useState("");
  const [parentLectureId, setParentLectureId] = useState(null);
  const [createChildAfterSave, setCreateChildAfterSave] = useState(false);
  const [errors, setErrors] = useState({});
  const [submitting, setSubmitting] = useState(false);
  const [showConfirmClose, setShowConfirmClose] = useState(false);

  // Media state
  const [mediaTempKey, setMediaTempKey] = useState(null);
  const [mediaType, setMediaType] = useState(null);
  const [mediaSize, setMediaSize] = useState(null);
  const [duration, setDuration] = useState(null);
  const [existingMediaUrl, setExistingMediaUrl] = useState(null);
  const [uploadedFileName, setUploadedFileName] = useState(null);

  // Document upload state (for type 2 - Document lectures)
  const [selectedDocumentFile, setSelectedDocumentFile] = useState(null);
  const [uploadingDocument, setUploadingDocument] = useState(false);
  const documentFileInputRef = useRef(null);

  // Parent lectures list (for dropdown)
  const [parentLectures, setParentLectures] = useState([]);

  // Tìm thông tin parent lecture để hiển thị breadcrumb
  const parentLectureInfo = useMemo(() => {
    // Nếu đang tạo child và có parentTitle từ prop
    if (isChildCreation && lectureToUpdate?.parentTitle) {
      return { title: lectureToUpdate.parentTitle, Title: lectureToUpdate.parentTitle };
    }
    // Nếu chọn parent từ dropdown
    if (!parentLectureId || parentLectures.length === 0) return null;
    return parentLectures.find(l => (l.lectureId || l.LectureId) === parentLectureId);
  }, [parentLectureId, parentLectures, isChildCreation, lectureToUpdate]);

  // Markdown toolbar
  const insertMarkdown = (tag) => {
    const area = textAreaRef.current;
    if (!area) return;

    const start = area.selectionStart;
    const end = area.selectionEnd;
    const text = area.value;
    const selected = text.substring(start, end) || "văn bản";
    let inserted = "";

    switch (tag) {
      case 'bold': inserted = `**${selected}**`; break;
      case 'italic': inserted = `_${selected}_`; break;
      case 'heading': inserted = `### ${selected}`; break;
      case 'list': inserted = `\n- ${selected}`; break;
      case 'code': inserted = `\`${selected}\``; break;
      default: inserted = selected;
    }

    const newVal = text.substring(0, start) + inserted + text.substring(end);
    setMarkdownContent(newVal);
    setTimeout(() => {
      area.focus();
      area.setSelectionRange(start + inserted.length, start + inserted.length);
    }, 0);
  };

  // Load parent lectures
  useEffect(() => {
    if (show && moduleId) {
      const loadParentLectures = async () => {
        try {
          const response = isAdmin
            ? await lectureService.getAdminLecturesByModule(moduleId)
            : await lectureService.getTeacherLecturesByModule(moduleId);

          if (response.data?.success && response.data?.data) {
            // Filter out current lecture if editing
            const filtered = isEditMode && lectureToUpdate
              ? response.data.data.filter(l => (l.lectureId || l.LectureId) !== (lectureToUpdate.lectureId || lectureToUpdate.LectureId))
              : response.data.data;
            setParentLectures(filtered);
          }
        } catch (error) {
          console.error("Error loading parent lectures:", error);
        }
      };
      loadParentLectures();
    }
  }, [show, moduleId, isAdmin, isEditMode, lectureToUpdate]);

  // Fetch full lecture detail when editing (to get markdownContent and mediaUrl)
  useEffect(() => {
    const fetchLectureDetail = async () => {
      // Only fetch if:
      // 1. Modal is shown
      // 2. In edit mode (not child creation)
      // 3. Have lectureId
      // 4. Not already loaded (check if markdownContent or mediaUrl exist)
      if (!show || !isEditMode || !lectureToUpdate) return;

      const lectureId = lectureToUpdate.lectureId || lectureToUpdate.LectureId;
      if (!lectureId) return;

      // If already have full data (markdownContent or mediaUrl), skip fetch
      const hasMarkdown = lectureToUpdate.markdownContent || lectureToUpdate.MarkdownContent;
      const hasMediaUrl = lectureToUpdate.mediaUrl || lectureToUpdate.MediaUrl;
      if (hasMarkdown !== undefined || hasMediaUrl !== undefined) {
        // Data already loaded, but might be null/empty - still valid
        return;
      }

      try {
        const response = isAdmin
          ? await lectureService.getAdminLectureById(lectureId)
          : await lectureService.getTeacherLectureById(lectureId); // Fixed: use Teacher API

        if (response.data?.success && response.data?.data) {
          const fullLectureData = response.data.data;

          // Update form with full data
          setTitle(fullLectureData.title || fullLectureData.Title || "");
          setOrderIndex(fullLectureData.orderIndex || fullLectureData.OrderIndex || 0);
          setNumberingLabel(fullLectureData.numberingLabel || fullLectureData.NumberingLabel || "");
          setLectureType(fullLectureData.type || fullLectureData.Type || 1);
          setMarkdownContent(fullLectureData.markdownContent || fullLectureData.MarkdownContent || "");
          setParentLectureId(fullLectureData.parentLectureId || fullLectureData.ParentLectureId || null);
          setDuration(fullLectureData.duration || fullLectureData.Duration || null);
          setExistingMediaUrl(fullLectureData.mediaUrl || fullLectureData.MediaUrl || null);
        }
      } catch (err) {
      }
    };

    fetchLectureDetail();
  }, [show, isEditMode, lectureToUpdate, isAdmin]);

  // Load lecture data when editing
  useEffect(() => {
    if (show) {
      if (lectureToUpdate) {
        // Check if this is for creating a child lecture
        if (lectureToUpdate._isChildCreation && lectureToUpdate.parentLectureId) {
          // Reset form but keep parent ID
          setTitle("");
          setOrderIndex(0);
          setNumberingLabel("");
          setLectureType(1);
          setMarkdownContent("");
          setParentLectureId(lectureToUpdate.parentLectureId); // Keep parent ID
          setCreateChildAfterSave(false); // Don't create grandchild by default
          setMediaTempKey(null);
          setMediaType(null);
          setMediaSize(null);
          setDuration(null);
          setExistingMediaUrl(null);
        } else {
          // Normal edit mode
          setTitle(lectureToUpdate.title || lectureToUpdate.Title || "");
          setOrderIndex(lectureToUpdate.orderIndex || lectureToUpdate.OrderIndex || 0);
          setNumberingLabel(lectureToUpdate.numberingLabel || lectureToUpdate.NumberingLabel || "");
          setLectureType(lectureToUpdate.type || lectureToUpdate.Type || 1); // Default: Content
          setMarkdownContent(lectureToUpdate.markdownContent || lectureToUpdate.MarkdownContent || "");
          setParentLectureId(lectureToUpdate.parentLectureId || lectureToUpdate.ParentLectureId || null);
          setDuration(lectureToUpdate.duration || lectureToUpdate.Duration || null);
          setExistingMediaUrl(lectureToUpdate.mediaUrl || lectureToUpdate.MediaUrl || null);
        }
      } else {
        resetForm();
      }
      setErrors({});
    }
  }, [show, lectureToUpdate]);

  // Reset form
  useEffect(() => {
    if (!show) {
      resetForm();
      setErrors({});
      setSubmitting(false);
    }
  }, [show]);

  const resetForm = () => {
    setTitle("");
    setOrderIndex(0);
    setNumberingLabel("");
    setLectureType(1); // Default: Content
    setMarkdownContent("");
    setParentLectureId(null);
    setCreateChildAfterSave(false);
    setMediaTempKey(null);
    setMediaType(null);
    setMediaSize(null);
    setDuration(null);
    setExistingMediaUrl(null);
    setUploadedFileName(null);
    setSelectedDocumentFile(null);
    setUploadingDocument(false);
    setShowConfirmClose(false);
  };

  // Check if form has data
  const hasFormData = () => {
    return (
      title.trim() !== "" ||
      markdownContent.trim() !== "" ||
      !!mediaTempKey ||
      !!existingMediaUrl
    );
  };

  // Handle close with confirmation
  const handleClose = () => {
    if (hasFormData() && !submitting) {
      setShowConfirmClose(true);
    } else {
      onClose();
    }
  };

  // Handle confirm close
  const handleConfirmClose = () => {
    setShowConfirmClose(false);
    onClose();
  };

  // Media upload handlers
  const handleMediaUploadSuccess = useCallback((tempKey, fileType, previewUrl, fileSize, extractedDuration) => {
    setMediaTempKey(tempKey);
    setMediaType(fileType);
    setMediaSize(fileSize || null);

    // Auto-set duration for video files if extracted successfully
    if (lectureType === 3 && extractedDuration !== null && extractedDuration !== undefined) {
      setDuration(extractedDuration);
    }

    setErrors(prev => ({ ...prev, media: null }));
  }, [lectureType]);

  const handleMediaRemove = useCallback(() => {
    setMediaTempKey(null);
    setMediaType(null);
    setMediaSize(null);
    setExistingMediaUrl(null);
    setUploadedFileName(null);
    setErrors(prev => ({ ...prev, media: null }));
  }, []);

  const handleMediaUploadError = useCallback((errorMessage) => {
    setErrors(prev => ({ ...prev, media: errorMessage }));
  }, []);

  // Document file handlers (for lecture type 2 - Document)
  const handleDocumentFileSelect = (e) => {
    const file = e.target.files[0];
    if (file) {
      // Validate file size (max 10MB)
      const maxSize = 10 * 1024 * 1024;
      if (file.size > maxSize) {
        setErrors(prev => ({ ...prev, media: "File quá lớn. Kích thước tối đa là 10MB." }));
        return;
      }

      // Validate file type
      const allowedExtensions = ['.pdf', '.doc', '.docx', '.txt', '.docm', '.dotx', '.dotm'];
      const fileName = file.name.toLowerCase();
      const hasValidExtension = allowedExtensions.some(ext => fileName.endsWith(ext));

      if (!hasValidExtension) {
        setErrors(prev => ({ ...prev, media: "Chỉ chấp nhận file PDF, DOC, DOCX, TXT, DOCM, DOTX, DOTM" }));
        if (documentFileInputRef.current) {
          documentFileInputRef.current.value = '';
        }
        return;
      }

      setSelectedDocumentFile(file);
      setMediaTempKey(null);
      setUploadedFileName(null);
      setErrors(prev => ({ ...prev, media: null }));
    }
  };

  const handleUploadDocument = async () => {
    if (!selectedDocumentFile) return;

    try {
      setUploadingDocument(true);

      const uploadResponse = await fileService.uploadTempFile(
        selectedDocumentFile,
        LECTURE_MEDIA_BUCKET,
        "temp"
      );

      if (uploadResponse.data?.success && uploadResponse.data?.data) {
        const resultData = uploadResponse.data.data;
        const tempKey = resultData.TempKey || resultData.tempKey;
        const imageType = resultData.ImageType || resultData.imageType || selectedDocumentFile.type;

        if (!tempKey) {
          throw new Error("Không nhận được TempKey từ server");
        }

        setMediaTempKey(tempKey);
        setUploadedFileName(selectedDocumentFile.name);

        // Type mapping - use SHORT MIME types to fit backend 50-char limit
        const extension = selectedDocumentFile?.name?.split('.').pop()?.toLowerCase();
        const typeMap = {
          'pdf': 'application/pdf',
          'doc': 'application/msword',
          'docx': 'application/docx', // Shortened from 69-char full MIME
          'txt': 'text/plain',
          'docm': 'application/docm',
          'dotx': 'application/dotx',
          'dotm': 'application/dotm'
        };

        const finalMediaType = typeMap[extension] || imageType?.substring(0, 50) || 'application/octet-stream';
        setMediaType(finalMediaType);
        setMediaSize(selectedDocumentFile.size);

        setErrors(prev => ({ ...prev, media: null }));
      } else {
        throw new Error(uploadResponse.data?.message || "Không thể upload document");
      }
    } catch (err) {
      console.error("Error uploading document:", err);
      setErrors(prev => ({ ...prev, media: err.response?.data?.message || "Không thể upload document. Vui lòng thử lại." }));
    } finally {
      setUploadingDocument(false);
    }
  };

  const handleRemoveDocument = () => {
    setSelectedDocumentFile(null);
    setMediaTempKey(null);
    setMediaType(null);
    setMediaSize(null);
    setUploadedFileName(null);
    setExistingMediaUrl(null);
    if (documentFileInputRef.current) {
      documentFileInputRef.current.value = '';
    }
    setErrors(prev => ({ ...prev, media: null }));
  };

  const formatFileSize = (bytes) => {
    if (bytes === 0) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + " " + sizes[i];
  };

  // Validation
  const validateForm = () => {
    const newErrors = {};

    if (!title.trim()) {
      newErrors.title = "Tiêu đề là bắt buộc";
    } else if (title.trim().length < 2 || title.trim().length > 255) {
      newErrors.title = "Tiêu đề phải từ 2 đến 255 ký tự";
    }

    if (orderIndex < 0 || orderIndex >= 1000) {
      newErrors.orderIndex = "Thứ tự phải từ 0 đến 999";
    }

    if (numberingLabel && numberingLabel.length > 50) {
      newErrors.numberingLabel = "Nhãn đánh số không được vượt quá 50 ký tự";
    }

    if (markdownContent && markdownContent.length > 5000000) {
      newErrors.markdownContent = "Nội dung Markdown không được vượt quá 5 triệu ký tự";
    }

    // Validate MediaType - max 50 characters (backend validator)
    if (mediaType && mediaType.length > 50) {
      newErrors.media = "Media type không được vượt quá 50 ký tự";
    }

    // Validate MediaSize - must be > 0 if provided (backend validator)
    if (mediaSize !== null && mediaSize !== undefined && mediaSize <= 0) {
      newErrors.media = "Media size phải lớn hơn 0";
    }

    // Validate Duration - must be >= 0 if provided (backend validator)
    if (duration !== null && duration !== undefined && duration < 0) {
      newErrors.duration = "Duration phải từ 0 trở lên";
    }

    // Validate required media for Video type
    if (lectureType === 3 && !mediaTempKey && !existingMediaUrl) {
      newErrors.media = "File video là bắt buộc";
    }

    // Validate required media for Document type
    if (lectureType === 2 && !mediaTempKey && !existingMediaUrl) {
      newErrors.media = "File tài liệu là bắt buộc";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;

    setSubmitting(true);
    try {
      // Ensure MediaType doesn't exceed 50 characters (backend validator)
      const trimmedMediaType = mediaType ? mediaType.substring(0, 50) : null;

      const lectureData = {
        moduleId: parseInt(moduleId),
        title: title.trim(),
        orderIndex: orderIndex || 0,
        numberingLabel: numberingLabel.trim() || null,
        type: lectureType,
        markdownContent: markdownContent.trim() || null,
        parentLectureId: parentLectureId || null,
        mediaTempKey: mediaTempKey || null,
        mediaType: trimmedMediaType,
        mediaSize: mediaSize && mediaSize > 0 ? mediaSize : null,
        duration: duration !== null && duration !== undefined && duration >= 0 ? duration : null,
      };

      let response;
      if (isEditMode) {
        const lectureId = lectureToUpdate.lectureId || lectureToUpdate.LectureId;
        response = isAdmin
          ? await lectureService.updateAdminLecture(lectureId, lectureData)
          : await lectureService.updateLecture(lectureId, lectureData);
      } else {
        response = isAdmin
          ? await lectureService.createAdminLecture(lectureData)
          : await lectureService.createLecture(lectureData);
      }

      if (response.data?.success) {
        const createdLecture = response.data.data;
        onSuccess(createdLecture);

        // If "create child after save" is checked and this is a new lecture (not edit)
        if (createChildAfterSave && !isEditMode && createdLecture) {
          const createdLectureId = createdLecture.lectureId || createdLecture.LectureId;
          // Close current modal and trigger create child modal
          onClose();
          // Use setTimeout to ensure modal closes before opening new one
          setTimeout(() => {
            // Call onSuccess with special flag to indicate we want to create child
            onSuccess({ ...createdLecture, _createChild: true, _parentId: createdLectureId });
          }, 100);
        } else {
          onClose();
        }
      } else {
        throw new Error(response.data?.message || "Thao tác thất bại");
      }
    } catch (error) {
      console.error("Error saving lecture:", error);
      setErrors({ submit: error.response?.data?.message || error.message || "Có lỗi xảy ra" });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <>
      <Modal show={show} onHide={handleClose} centered size="xl" className="clm-modal modal-modern" dialogClassName="clm-modal-dialog">
        <Modal.Header className="clm-header">
          <Modal.Title className="clm-title">
            {isEditMode ? "Cập nhật Lecture" : isChildCreation ? "Tạo Lecture con" : "Tạo Lecture mới"}
          </Modal.Title>
        </Modal.Header>

        <Modal.Body className="clm-body">
          <Form onSubmit={handleSubmit}>
            {/* BREADCRUMB - Hiển thị vị trí trong cây khi tạo con */}
            {(isChildCreation || parentLectureId) && parentLectureInfo && (
              <Alert variant="info" className="clm-breadcrumb">
                <div className="clm-breadcrumb__header">
                  <FaSitemap className="clm-breadcrumb__icon" />
                  <span>Vị trí trong cấu trúc bài giảng:</span>
                </div>
                <div className="clm-breadcrumb__path">
                  {moduleName && (
                    <>
                      <span className="clm-breadcrumb__item clm-breadcrumb__item--module">
                        📚 {moduleName}
                      </span>
                      <FaArrowRight className="clm-breadcrumb__arrow" />
                    </>
                  )}
                  <span className="clm-breadcrumb__item clm-breadcrumb__item--parent">
                    📖 {parentLectureInfo.title || parentLectureInfo.Title}
                  </span>
                  <FaArrowRight className="clm-breadcrumb__arrow" />
                  <span className="clm-breadcrumb__item clm-breadcrumb__item--new">
                    🆕 {title || "(Bài giảng mới)"}
                  </span>
                </div>
              </Alert>
            )}

            {/* SECTION 1: THÔNG TIN CƠ BẢN */}
            <div className="clm-section">
              <div className="clm-section__title"><FaBook /> Thông tin cơ bản</div>
              <Row className="g-3">
                <Col md={12}>
                  <Form.Label className="fw-bold">Tiêu đề <span className="text-danger">*</span></Form.Label>
                  <Form.Control
                    type="text"
                    isInvalid={!!errors.title}
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    placeholder="Nhập tiêu đề lecture"
                    maxLength={255}
                  />
                  {errors.title && <Form.Control.Feedback type="invalid" className="d-block">{errors.title}</Form.Control.Feedback>}
                </Col>
                <Col md={4}>
                  <Form.Label className="fw-bold">Loại lecture</Form.Label>
                  <Form.Select
                    value={lectureType}
                    onChange={(e) => setLectureType(parseInt(e.target.value))}
                  >
                    {LECTURE_TYPES.map((type) => (
                      <option key={type.value} value={type.value}>
                        {type.label}
                      </option>
                    ))}
                  </Form.Select>
                </Col>
                <Col md={4}>
                  <Form.Label className="fw-bold">Thứ tự</Form.Label>
                  <Form.Control
                    type="number"
                    isInvalid={!!errors.orderIndex}
                    value={orderIndex}
                    onChange={(e) => setOrderIndex(parseInt(e.target.value) || 0)}
                    min="0"
                    max="999"
                  />
                  {errors.orderIndex && <Form.Control.Feedback type="invalid" className="d-block">{errors.orderIndex}</Form.Control.Feedback>}
                  <small className="text-muted">Để 0 để tự động đặt</small>
                </Col>
                <Col md={4}>
                  <Form.Label className="fw-bold">Nhãn đánh số</Form.Label>
                  <Form.Control
                    type="text"
                    isInvalid={!!errors.numberingLabel}
                    value={numberingLabel}
                    onChange={(e) => setNumberingLabel(e.target.value)}
                    placeholder="VD: 1.1, 2.3..."
                    maxLength={50}
                  />
                  {errors.numberingLabel && <Form.Control.Feedback type="invalid" className="d-block">{errors.numberingLabel}</Form.Control.Feedback>}
                </Col>
                {parentLectures.length > 0 && (
                  <Col md={12}>
                    <Form.Label className="fw-bold">Lecture cha</Form.Label>
                    <Form.Select
                      value={parentLectureId || ""}
                      onChange={(e) => setParentLectureId(e.target.value ? parseInt(e.target.value) : null)}
                    >
                      <option value="">Không có (Lecture gốc)</option>
                      {parentLectures.map((lec) => (
                        <option key={lec.lectureId || lec.LectureId} value={lec.lectureId || lec.LectureId}>
                          {lec.title || lec.Title}
                        </option>
                      ))}
                    </Form.Select>
                  </Col>
                )}

                {/* Option to create child lecture after saving (only for new lectures, not editing) */}
                {!isEditMode && !parentLectureId && (
                  <Col md={12}>
                    <Form.Check
                      type="checkbox"
                      id="createChildAfterSave"
                      label="Tạo lecture con ngay sau khi lưu"
                      checked={createChildAfterSave}
                      onChange={(e) => setCreateChildAfterSave(e.target.checked)}
                      className="mt-2"
                    />
                    <small className="text-muted d-block mt-1">
                      Sau khi tạo lecture này, modal sẽ tự động mở để tạo lecture con
                    </small>
                  </Col>
                )}
              </Row>
            </div>

            {/* SECTION 2: NỘI DUNG MARKDOWN (Chỉ cho Content và Document) */}
            {(lectureType === 1 || lectureType === 2) && (
              <div className="clm-section">
                <div className="clm-section__title"><FaMarkdown /> Nội dung Markdown</div>
                <div className="clm-markdown-toolbar">
                  <button type="button" className="clm-toolbar-btn" onClick={() => insertMarkdown('bold')} title="In đậm"><FaBold /></button>
                  <button type="button" className="clm-toolbar-btn" onClick={() => insertMarkdown('italic')} title="In nghiêng"><FaItalic /></button>
                  <button type="button" className="clm-toolbar-btn" onClick={() => insertMarkdown('heading')} title="Tiêu đề"><FaHeading /></button>
                  <button type="button" className="clm-toolbar-btn" onClick={() => insertMarkdown('list')} title="Danh sách"><FaListUl /></button>
                  <button type="button" className="clm-toolbar-btn" onClick={() => insertMarkdown('code')} title="Mã code"><FaCode /></button>
                </div>
                <div className="clm-markdown-editor">
                  <textarea
                    ref={textAreaRef}
                    className={`clm-markdown-textarea ${errors.markdownContent ? "border-danger" : ""}`}
                    value={markdownContent}
                    onChange={(e) => setMarkdownContent(e.target.value)}
                    placeholder="Viết nội dung bằng Markdown..."
                    maxLength={5000000}
                  />
                  <div className="clm-markdown-preview">
                    {markdownContent ? (
                      <ReactMarkdown remarkPlugins={[remarkGfm]}>{markdownContent}</ReactMarkdown>
                    ) : (
                      <div className="text-muted h-100 d-flex align-items-center justify-content-center">Xem trước nội dung...</div>
                    )}
                  </div>
                </div>
                <div className="d-flex justify-content-between align-items-center mt-2">
                  {errors.markdownContent && (
                    <Form.Control.Feedback type="invalid" className="d-block text-danger small mb-0">
                      {errors.markdownContent}
                    </Form.Control.Feedback>
                  )}
                  <div className={`clm-char-count ms-auto ${markdownContent.length > 4500000 ? 'text-warning' : markdownContent.length > 4800000 ? 'text-danger' : ''}`}>
                    {markdownContent.length.toLocaleString('vi-VN')} / 5,000,000 ký tự
                  </div>
                </div>
              </div>
            )}

            {/* SECTION 3: MEDIA - VIDEO */}
            {lectureType === 3 && (
              <div className="clm-section">
                <div className="clm-section__title"><FaVideo /> Video</div>
                <Row className="g-3">
                  <Col md={6}>
                    <Form.Label className="fw-bold">File Video <span className="text-danger">*</span></Form.Label>
                    <FileUpload
                      bucket={LECTURE_MEDIA_BUCKET}
                      accept="video/*"
                      maxSize={100}
                      existingUrl={existingMediaUrl}
                      onUploadSuccess={handleMediaUploadSuccess}
                      onRemove={handleMediaRemove}
                      onError={handleMediaUploadError}
                      label="Chọn video"
                      hint="Hỗ trợ video files (MP4, AVI, MOV...) - Tối đa 100MB"
                    />
                    {errors.media && <div className="text-danger small mt-1">{errors.media}</div>}
                  </Col>
                  <Col md={6}>
                    <Form.Label className="fw-bold">Duration (giây)</Form.Label>
                    <Form.Control
                      type="number"
                      isInvalid={!!errors.duration}
                      value={duration !== null && duration !== undefined ? duration : ""}
                      onChange={(e) => {
                        const value = e.target.value;
                        setDuration(value ? parseInt(value) : null);
                        if (errors.duration) {
                          setErrors(prev => ({ ...prev, duration: null }));
                        }
                      }}
                      placeholder="Tự động lấy từ video hoặc nhập thủ công"
                      min="0"
                    />
                    {errors.duration && <Form.Control.Feedback type="invalid" className="d-block">{errors.duration}</Form.Control.Feedback>}
                    <small className="text-muted d-block mt-1">
                      {duration !== null && duration !== undefined
                        ? `Đã tự động lấy: ${duration} giây (${Math.floor(duration / 60)}:${(duration % 60).toString().padStart(2, '0')})`
                        : "Sẽ tự động lấy từ video khi upload"}
                    </small>
                  </Col>
                </Row>
              </div>
            )}

            {/* SECTION 4: MEDIA - DOCUMENT */}
            {lectureType === 2 && (
              <div className="clm-section">
                <div className="clm-section__title"><FaFileAlt /> Tài liệu</div>
                <Row className="g-3">
                  <Col md={12}>
                    <Form.Label className="fw-bold">File Document</Form.Label>

                    {/* Existing document display */}
                    {existingMediaUrl && !selectedDocumentFile && (
                      <div className="mb-3 p-3 border rounded bg-light">
                        <div className="d-flex align-items-center justify-content-between">
                          <div>
                            <FaFileAlt className="me-2 text-primary" />
                            <span>File đính kèm hiện tại</span>
                          </div>
                          <a href={existingMediaUrl} target="_blank" rel="noopener noreferrer" className="btn btn-sm btn-outline-primary">
                            Xem file
                          </a>
                        </div>
                      </div>
                    )}

                    {/* Selected or uploaded file display */}
                    {selectedDocumentFile ? (
                      <div className="p-3 border rounded">
                        <div className="d-flex align-items-center justify-content-between mb-2">
                          <div>
                            <FaFileAlt className="me-2 text-primary" />
                            <strong>{selectedDocumentFile?.name || "Unknown file"}</strong>
                            <small className="text-muted ms-2">({formatFileSize(selectedDocumentFile?.size || 0)})</small>
                          </div>
                          <div>
                            {!mediaTempKey && (
                              <Button
                                variant="primary"
                                size="sm"
                                onClick={handleUploadDocument}
                                disabled={uploadingDocument}
                                className="me-2"
                              >
                                {uploadingDocument ? "Đang upload..." : "Upload file"}
                              </Button>
                            )}
                            {mediaTempKey && uploadedFileName && (
                              <span className="badge bg-success me-2">
                                <FaCheckCircle className="me-1" /> Đã upload
                              </span>
                            )}
                            <Button
                              variant="outline-danger"
                              size="sm"
                              onClick={handleRemoveDocument}
                            >
                              <FaTimes /> Xóa
                            </Button>
                          </div>
                        </div>
                      </div>
                    ) : (
                      <div className="border border-dashed rounded p-4 text-center">
                        <input
                          ref={documentFileInputRef}
                          type="file"
                          id="document-file-input"
                          className="d-none"
                          onChange={handleDocumentFileSelect}
                          accept=".pdf,.doc,.docx,.txt,.docm,.dotx,.dotm"
                        />
                        <label htmlFor="document-file-input" className="cursor-pointer">
                          <FaFileUpload size={32} className="text-primary mb-2" />
                          <div>Chọn file để upload</div>
                          <small className="text-muted">(PDF, DOC, DOCX, TXT, DOCM, DOTX, DOTM - tối đa 10MB)</small>
                        </label>
                      </div>
                    )}

                    {errors.media && <div className="text-danger small mt-1">{errors.media}</div>}
                  </Col>
                </Row>
              </div>
            )}

            {errors.submit && <div className="alert alert-danger mt-3">{errors.submit}</div>}
          </Form>
        </Modal.Body>

        <Modal.Footer className="clm-footer">
          <Button variant="secondary" onClick={handleClose} disabled={submitting}>Hủy</Button>
          <Button className="clm-btn-submit" onClick={handleSubmit} disabled={submitting || !title.trim()}>
            {submitting ? "Đang lưu..." : (isEditMode ? "Cập nhật" : isChildCreation ? "Tạo bài con" : "Tạo Lecture")}
          </Button>
        </Modal.Footer>
      </Modal>

      {/* Confirm Close Modal */}
      <ConfirmModal
        isOpen={showConfirmClose}
        onClose={() => setShowConfirmClose(false)}
        onConfirm={handleConfirmClose}
        title="Xác nhận đóng"
        message={`Bạn có dữ liệu chưa được lưu. Bạn có chắc chắn muốn ${isEditMode ? "hủy cập nhật" : "hủy tạo"} Lecture không?`}
        confirmText="Đóng"
        cancelText="Tiếp tục"
        type="warning"
      />
    </>
  );
}
