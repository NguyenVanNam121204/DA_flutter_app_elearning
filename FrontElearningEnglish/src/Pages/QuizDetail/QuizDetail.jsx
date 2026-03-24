import React, { useState, useEffect, useRef, useCallback } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { Container, Row, Col, Button } from "react-bootstrap";
import MainHeader from "../../Components/Header/MainHeader";
import QuizTimer from "../../Components/Quiz/QuizTimer/QuizTimer";
import QuizNavigation from "../../Components/Quiz/QuizNavigation/QuizNavigation";
import QuestionCard from "../../Components/Quiz/QuestionCard/QuestionCard";
import ConfirmModal from "../../Components/Common/ConfirmModal/ConfirmModal";
import NotificationModal from "../../Components/Common/NotificationModal/NotificationModal";
import { quizAttemptService } from "../../Services/quizAttemptService";
import { quizService } from "../../Services/quizService";
import "./QuizDetail.css";

export default function QuizDetail() {
    const { courseId, lessonId, moduleId, quizId, attemptId } = useParams();
    const navigate = useNavigate();
    
    const [quizAttempt, setQuizAttempt] = useState(null);
    const [quiz, setQuiz] = useState(null);
    const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
    const [answers, setAnswers] = useState({}); // { questionId: answer }
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [submitting, setSubmitting] = useState(false);
    const [showSubmitModal, setShowSubmitModal] = useState(false);
    const [notification, setNotification] = useState({ isOpen: false, type: "info", message: "" });
    
    const timeSpentRef = useRef(0);
    const timerIntervalRef = useRef(null);
    const isFetchingRef = useRef(false);
    const fetchedKeyRef = useRef(null);
    const [remainingTime, setRemainingTime] = useState(null); // State để update timer real-time
    const endTimeRef = useRef(null); // Lưu endTime được tính từ startedAt + Duration
    const autoSubmitCalledRef = useRef(false); // Để tránh gọi auto-submit nhiều lần
    const saveAnswerTimeoutRef = useRef({}); // Debounce timers cho từng questionId
    const savingAnswersRef = useRef(new Set()); // Track các answer đang được save

    // Flatten all questions from sections and groups
    const getAllQuestions = () => {
        if (!quizAttempt) {
            console.log("No quizAttempt in getAllQuestions");
            return [];
        }
        
        const sections = quizAttempt.QuizSections || quizAttempt.quizSections || [];
        console.log("getAllQuestions - sections:", sections.length);
        
        if (!sections || sections.length === 0) {
            console.log("No sections found");
            return [];
        }
        
        const allQuestions = [];
        sections.forEach((section, sectionIdx) => {
            // New Structure: QuizSections -> Items (Group/Question)
            const items = section.Items || section.items || [];
            
            if (items.length > 0) {
                console.log(`Section ${sectionIdx}: Found ${items.length} items`);
                items.forEach(item => {
                    const type = item.ItemType || item.itemType;
                    
                    if (type === "Question") {
                        // Item itself acts as a question wrapper or contains question props
                        // Make sure we have a valid question object
                        if (item.QuestionId || item.questionId) {
                            allQuestions.push(item);
                        }
                    } else if (type === "Group") {
                        const groupQuestions = item.Questions || item.questions || [];
                        if (Array.isArray(groupQuestions)) {
                            // Attach group info to each question in the group
                            const groupInfo = {
                                groupName: item.Name || item.name,
                                groupTitle: item.Title || item.title,
                                groupDescription: item.Description || item.description,
                                groupImgUrl: item.ImgUrl || item.imgUrl,
                                groupVideoUrl: item.VideoUrl || item.videoUrl,
                                groupSumScore: item.SumScore || item.sumScore
                            };
                            
                            groupQuestions.forEach(q => {
                                allQuestions.push({
                                    ...q,
                                    _groupInfo: groupInfo // Add group info as metadata
                                });
                            });
                        }
                    }
                });
            } else {
                // Fallback: Legacy/Alternative Structure (Direct Questions/QuizGroups lists)
                const questions = section.Questions || section.questions || [];
                const groups = section.QuizGroups || section.quizGroups || [];
                
                console.log(`Section ${sectionIdx} (Legacy): ${questions.length} direct questions, ${groups.length} groups`);
                
                if (Array.isArray(questions) && questions.length > 0) {
                    allQuestions.push(...questions);
                }
                
                if (Array.isArray(groups) && groups.length > 0) {
                    groups.forEach((group) => {
                        const groupQuestions = group.Questions || group.questions || [];
                        if (Array.isArray(groupQuestions) && groupQuestions.length > 0) {
                            // Attach group info to legacy structure as well
                            const groupInfo = {
                                groupName: group.Name || group.name,
                                groupTitle: group.Title || group.title,
                                groupDescription: group.Description || group.description,
                                groupImgUrl: group.ImgUrl || group.imgUrl,
                                groupVideoUrl: group.VideoUrl || group.videoUrl,
                                groupSumScore: group.SumScore || group.sumScore
                            };
                            
                            groupQuestions.forEach(q => {
                                allQuestions.push({
                                    ...q,
                                    _groupInfo: groupInfo
                                });
                            });
                        }
                    });
                }
            }
        });
        
        console.log("Total questions flattened:", allQuestions.length);
        return allQuestions;
    };

    const questions = getAllQuestions();
    const currentQuestion = questions[currentQuestionIndex];

    useEffect(() => {
        // Tạo key duy nhất cho quizId và attemptId hiện tại
        const currentKey = `${quizId || ''}-${attemptId || ''}`;
        
        // Nếu đã fetch cho key này rồi, không fetch lại
        if (fetchedKeyRef.current === currentKey) {
            console.log("Already fetched for key:", currentKey);
            return;
        }

        // Nếu đang fetch, không fetch lại (tránh infinite loop)
        if (isFetchingRef.current) {
            console.log("Already fetching, skipping...");
            return;
        }

        // Phải có quizId hoặc attemptId
        if (!quizId && !attemptId) {
            setError("Thiếu thông tin quizId hoặc attemptId");
            setLoading(false);
            return;
        }

        // Mark as fetched và bắt đầu fetch
        fetchedKeyRef.current = currentKey;
        isFetchingRef.current = true;
        
        console.log("Starting fetch for key:", currentKey);
        
        fetchQuizAttempt()
            .then(() => {
                console.log("Fetch completed successfully");
            })
            .catch((err) => {
                console.error("Fetch error:", err);
            })
            .finally(() => {
                isFetchingRef.current = false;
                console.log("Fetch finally - isFetchingRef reset");
            });

        return () => {
            if (timerIntervalRef.current) {
                clearInterval(timerIntervalRef.current);
                timerIntervalRef.current = null;
            }
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [quizId, attemptId]);

    // Auto-save progress to localStorage whenever quizAttempt updates
    useEffect(() => {
        if (quizAttempt) {
            const status = quizAttempt.Status !== undefined ? quizAttempt.Status : quizAttempt.status;
            console.log(`💾 [AutoSave] Check Status: ${status} (Type: ${typeof status})`);

            // Loose check for status 0 or 1, OR if status is missing (assume active)
            // Backend Enum: 0=Started, 1=InProgress
            if (status === 0 || status === 1 || status === undefined) {
                const aId = quizAttempt.attemptId || quizAttempt.AttemptId || attemptId;
                const qId = quizAttempt.quizId || quizAttempt.QuizId || quizId;
                
                if (aId && qId) {
                    const progressKey = `quiz_in_progress_${qId}`;
                    const progressData = {
                        quizId: qId,
                        attemptId: aId,
                        courseId,
                        lessonId,
                        moduleId,
                        startedAt: quizAttempt.StartedAt || quizAttempt.startedAt,
                        status: status ?? 1 // Default to 1 if missing
                    };
                    
                    console.log(`💾 [AutoSave] WRITING to ${progressKey}`, progressData);
                    try {
                        localStorage.setItem(progressKey, JSON.stringify(progressData));
                        // Verify immediately
                        const verify = localStorage.getItem(progressKey);
                        console.log(`💾 [AutoSave] Verification read:`, verify ? "Success" : "Failed");
                    } catch (e) {
                        console.error("💾 [AutoSave] Write Failed:", e);
                    }
                } else {
                    console.warn("💾 [AutoSave] Missing IDs - aId:", aId, "qId:", qId);
                }
            } else {
                const qId = quizAttempt.quizId || quizAttempt.QuizId || quizId;
                console.log(`🗑️ [AutoSave] Status ${status} is not active. Removing key for ${qId}`);
                if (qId) localStorage.removeItem(`quiz_in_progress_${qId}`);
            }
        }
    }, [quizAttempt, quizId, courseId, lessonId, moduleId, attemptId]);

    // Cleanup: Clear all debounce timers khi component unmount
    useEffect(() => {
        const savingAnswers = savingAnswersRef.current;
        return () => {
            // Clear tất cả debounce timers
            Object.values(saveAnswerTimeoutRef.current).forEach(timeout => {
                if (timeout) clearTimeout(timeout);
            });
            saveAnswerTimeoutRef.current = {};
            savingAnswers.clear();
        };
    }, []);

    const fetchQuizAttempt = async () => {
        try {
            setLoading(true);
            setError("");

            console.log("=== Fetching quiz attempt ===");
            console.log("quizId:", quizId, "attemptId:", attemptId);

            let attempt = null;
            
            // QUAN TRỌNG: Nếu đã có attemptId trong URL, CHỈ gọi resume, KHÔNG gọi start
            // Điều này tránh infinite loop khi navigate
            if (attemptId) {
                console.log("🔍 [QuizDetail] Has attemptId in URL:", attemptId);
                console.log("🔍 [QuizDetail] Calling resume API directly...");
                
                try {
                    // Call resume API directly (it will check status internally)
                    const resumeResponse = await quizAttemptService.resume(attemptId);
                    console.log("📥 [QuizDetail] RESUME API response:", resumeResponse.data);
                    
                    if (resumeResponse.data?.success && resumeResponse.data?.data) {
                        attempt = resumeResponse.data.data;
                        console.log("✅ [QuizDetail] Resume successful");
                        
                        // Check status from resumed attempt
                        const status = attempt.Status !== undefined ? attempt.Status : attempt.status;
                        console.log("📊 [QuizDetail] Attempt status from resume:", status);
                        
                        // Status 0 = Started, 1 = InProgress -> Both are valid for resuming
                        // Status 2 = Submitted, 3 = Graded -> Cannot resume
                        if (status !== 0 && status !== 1) {
                            // Attempt đã submit hoặc không còn InProgress
                            console.error("❌ [QuizDetail] Attempt is not in progress/started. Status:", status);
                            setError("Bài quiz này đã được nộp hoặc kết thúc. Vui lòng quay lại danh sách bài tập.");
                            setLoading(false);
                            return;
                        }
                        
                        // Lưu quiz attempt vào localStorage để có thể tiếp tục sau
                        const attemptIdToSave = attempt.attemptId || attempt.AttemptId;
                        const quizIdToSave = attempt.quizId || attempt.QuizId || quizId;
                        if (attemptIdToSave && quizIdToSave) {
                            const quizProgress = {
                                quizId: quizIdToSave,
                                attemptId: attemptIdToSave,
                                courseId,
                                lessonId,
                                moduleId,
                                startedAt: attempt.StartedAt || attempt.startedAt,
                                status: attempt.Status || attempt.status
                            };
                            localStorage.setItem(`quiz_in_progress_${quizIdToSave}`, JSON.stringify(quizProgress));
                            console.log("💾 [QuizDetail] Quiz progress saved to localStorage for quizId:", quizIdToSave);
                        }
                    } else {
                        console.error("❌ [QuizDetail] Resume failed:", resumeResponse.data?.message);
                        console.error("❌ [QuizDetail] Resume response:", resumeResponse.data);
                        // Nếu resume fail, có thể attempt đã submit hoặc không tồn tại
                        // KHÔNG tự động start mới khi đã có attemptId trong URL
                        // Chỉ báo lỗi và để user quyết định
                        setError(resumeResponse.data?.message || "Không thể tiếp tục làm bài. Attempt có thể đã được nộp hoặc không tồn tại.");
                        setLoading(false);
                        return;
                    }
                } catch (err) {
                    console.error("❌ [QuizDetail] Resume API error:", err);
                    console.error("❌ [QuizDetail] Error details:", {
                        message: err.message,
                        response: err.response?.data,
                        status: err.response?.status,
                        url: err.config?.url,
                        method: err.config?.method,
                        stack: err.stack
                    });
                    
                    // Check if error is because attempt is already submitted or not found
                    if (err.response?.status === 400) {
                        setError("Bài quiz này đã được nộp hoặc không thể tiếp tục. Vui lòng quay lại danh sách bài tập để làm quiz mới.");
                    } else if (err.response?.status === 404) {
                        setError("Không tìm thấy bài quiz này. Có thể attempt đã bị xóa hoặc không tồn tại. Vui lòng quay lại danh sách bài tập để làm quiz mới.");
                    } else {
                        setError(err.response?.data?.message || "Không thể tiếp tục làm bài. Vui lòng thử lại.");
                    }
                    setLoading(false);
                    return;
                }
            } 
            // Nếu KHÔNG có attemptId, gọi start API (chỉ khi có quizId)
            else if (quizId) {
                console.log("No attemptId, calling start API...");
                try {
                    const startResponse = await quizAttemptService.start(quizId);
                    console.log("Start API response:", startResponse.data);
                    
                    if (startResponse.data?.success && startResponse.data?.data) {
                        attempt = startResponse.data.data;
                        const newAttemptId = attempt.AttemptId || attempt.attemptId;
                        const newQuizId = attempt.QuizId || attempt.quizId || quizId;
                        
                        console.log("✅ [QuizDetail] Start successful, newAttemptId:", newAttemptId);
                        
                        // Lưu quiz attempt vào localStorage để có thể tiếp tục sau
                        if (newAttemptId && newQuizId) {
                            const quizProgress = {
                                quizId: newQuizId,
                                attemptId: newAttemptId,
                                courseId,
                                lessonId,
                                moduleId,
                                startedAt: attempt.StartedAt || attempt.startedAt,
                                status: attempt.Status || attempt.status
                            };
                            localStorage.setItem(`quiz_in_progress_${newQuizId}`, JSON.stringify(quizProgress));
                            console.log("💾 [QuizDetail] Quiz progress saved to localStorage for quizId:", newQuizId);
                        }
                        
                        // QUAN TRỌNG: Chỉ navigate một lần khi start thành công
                        // Reset fetchedKeyRef để useEffect có thể fetch lại với attemptId mới
                        fetchedKeyRef.current = null;
                        
                        // Navigate với replace: true để tránh history stack
                        navigate(`/course/${courseId}/lesson/${lessonId}/module/${moduleId}/quiz/${newQuizId}/attempt/${newAttemptId}`, { replace: true });
                        
                        // KHÔNG set loading = false ở đây, để useEffect fetch lại với attemptId mới
                        // useEffect sẽ tự động fetch lại với attemptId mới
                        return;
                    } else {
                        console.error("✗ Start API failed:", startResponse.data);
                        setError(startResponse.data?.message || "Không thể bắt đầu làm quiz");
                        setLoading(false);
                        return;
                    }
                } catch (err) {
                    console.error("✗ Start API error:", err);
                    console.error("Error details:", err.response?.data);
                    setError(err.response?.data?.message || "Không thể bắt đầu làm quiz");
                    setLoading(false);
                    return;
                }
            } else {
                // Không có cả quizId và attemptId
                console.error("✗ Missing both quizId and attemptId");
                setError("Thiếu thông tin quizId hoặc attemptId");
                setLoading(false);
                return;
            }
            
            // Nếu vẫn không có attempt sau tất cả các bước
            if (!attempt) {
                console.error("✗ No attempt found after all attempts");
                setError("Không thể tải thông tin quiz. Vui lòng thử lại.");
                setLoading(false);
                return;
            }

            if (attempt) {
                // Debug: Log attempt structure
                console.log("Attempt data:", attempt);
                console.log("QuizSections:", attempt.quizSections || attempt.QuizSections);
                
                // Backend trả về QuizSections (PascalCase) theo DTO
                const sections = attempt.QuizSections || attempt.quizSections || [];
                console.log("Sections found:", sections.length);
                
                // Kiểm tra xem có questions không (Logic updated for Items structure)
                let totalQuestions = 0;
                sections.forEach((section, idx) => {
                    // Check new Items structure first
                    const items = section.Items || section.items || [];
                    if (items.length > 0) {
                        items.forEach(item => {
                            const type = item.ItemType || item.itemType;
                            if (type === "Question") {
                                totalQuestions++;
                            } else if (type === "Group") {
                                const gq = item.Questions || item.questions || [];
                                totalQuestions += gq.length;
                            }
                        });
                    } else {
                        // Fallback Legacy
                        const sectionQuestions = section.Questions || section.questions || [];
                        const groups = section.QuizGroups || section.quizGroups || [];
                        let groupQuestions = 0;
                        groups.forEach(group => {
                            const gq = group.Questions || group.questions || [];
                            groupQuestions += gq.length;
                        });
                        totalQuestions += sectionQuestions.length + groupQuestions;
                    }
                    console.log(`Section ${idx}: found ${totalQuestions} questions so far`);
                });
                console.log("Total questions found:", totalQuestions);
                
                // FORCE PROCEED even if 0 questions found (to debug saving logic)
                if (totalQuestions === 0) {
                    console.warn("⚠️ Warning: No questions found by counter, but proceeding to set state.");
                }
                
                console.log("✅ Setting quizAttempt state:", attempt);
                setQuizAttempt(attempt);
                
                // Load existing answers - handle both camelCase and PascalCase (Updated for Items)
                const existingAnswers = {};
                
                sections.forEach(section => {
                    const items = section.Items || section.items || [];
                    if (items.length > 0) {
                        items.forEach(item => {
                            const type = item.ItemType || item.itemType;
                            if (type === "Question") {
                                const q = item;
                                const questionId = q.QuestionId || q.questionId;
                                const userAnswer = q.UserAnswer !== undefined ? q.UserAnswer : (q.userAnswer !== undefined ? q.userAnswer : null);
                                if (userAnswer !== null && userAnswer !== undefined) existingAnswers[questionId] = userAnswer;
                            } else if (type === "Group") {
                                const groupQuestions = item.Questions || item.questions || [];
                                groupQuestions.forEach(q => {
                                    const questionId = q.QuestionId || q.questionId;
                                    const userAnswer = q.UserAnswer !== undefined ? q.UserAnswer : (q.userAnswer !== undefined ? q.userAnswer : null);
                                    if (userAnswer !== null && userAnswer !== undefined) existingAnswers[questionId] = userAnswer;
                                });
                            }
                        });
                    } else {
                        // Legacy loading answers
                        const questions = section.Questions || section.questions || [];
                        const groups = section.QuizGroups || section.quizGroups || [];
                        
                        questions.forEach(q => {
                            const questionId = q.QuestionId || q.questionId;
                            const userAnswer = q.UserAnswer !== undefined ? q.UserAnswer : (q.userAnswer !== undefined ? q.userAnswer : null);
                            if (userAnswer !== null && userAnswer !== undefined) existingAnswers[questionId] = userAnswer;
                        });
                        
                        groups.forEach(group => {
                            const groupQuestions = group.Questions || group.questions || [];
                            groupQuestions.forEach(q => {
                                const questionId = q.QuestionId || q.questionId;
                                const userAnswer = q.UserAnswer !== undefined ? q.UserAnswer : (q.userAnswer !== undefined ? q.userAnswer : null);
                                if (userAnswer !== null && userAnswer !== undefined) existingAnswers[questionId] = userAnswer;
                            });
                        });
                    }
                });
                setAnswers(existingAnswers);

                // Fetch quiz info for duration and other details
                // Try to get Duration from attempt first (if available)
                const attemptDuration = attempt.Duration || attempt.duration;
                const attemptQuizInfo = attempt.Quiz || attempt.quiz;
                
                if (attemptQuizInfo) {
                    // Quiz info already in attempt response
                    console.log("✓ Quiz info found in attempt response:", attemptQuizInfo);
                    setQuiz(attemptQuizInfo);
                } else if (attemptDuration !== null && attemptDuration !== undefined) {
                    // Duration in attempt, create minimal quiz object
                    console.log("✓ Duration found in attempt:", attemptDuration);
                    setQuiz({ Duration: attemptDuration, duration: attemptDuration });
                } else {
                    // Fetch quiz info from API
                    const quizIdToFetch = attempt.QuizId || attempt.quizId || quizId;
                    if (quizIdToFetch) {
                        try {
                            console.log("Fetching quiz info for quizId:", quizIdToFetch);
                            const quizResponse = await quizService.getById(quizIdToFetch);
                            console.log("Quiz API response:", quizResponse.data);
                            
                            if (quizResponse.data?.success && quizResponse.data?.data) {
                                // Handle array response (getById might return array)
                                const quizData = Array.isArray(quizResponse.data.data) 
                                    ? quizResponse.data.data[0] 
                                    : quizResponse.data.data;
                                
                                console.log("✓ Quiz data loaded:", quizData);
                                console.log("Quiz Duration:", quizData.Duration || quizData.duration, "minutes");
                                
                                setQuiz(quizData);
                            } else {
                                console.warn("Quiz API response not successful:", quizResponse.data);
                            }
                        } catch (err) {
                            console.error("✗ Error fetching quiz info:", err);
                            console.error("Error details:", err.response?.data);
                            // Continue even if quiz info fetch fails - timer will show "Không giới hạn"
                        }
                    } else {
                        console.warn("No quizId to fetch");
                    }
                }
                
                // Sau khi set quizAttempt và load answers, set loading = false
                console.log("✓ Quiz attempt loaded successfully");
                setLoading(false);
            }
        } catch (err) {
            console.error("✗ Unexpected error in fetchQuizAttempt:", err);
            console.error("Error details:", err.response?.data);
            setError(err.response?.data?.message || "Không thể tải thông tin quiz");
            setLoading(false);
            // KHÔNG reset fetchedKeyRef ở đây để tránh retry loop
            // Chỉ reset khi user thực sự cần retry (ví dụ: click retry button)
        }
        // KHÔNG có finally block ở đây vì mỗi return đã set loading = false
        // isFetchingRef được reset trong useEffect's finally
    };

    const handleSubmitAnswer = useCallback(async (questionId, answer) => {
        try {
            // Call API to submit answer - use attemptId from quizAttempt if available
            const currentAttemptId = quizAttempt?.attemptId || quizAttempt?.AttemptId || attemptId;
            if (currentAttemptId && questionId) {
                const response = await quizAttemptService.updateAnswer(currentAttemptId, {
                    questionId,
                    userAnswer: answer
                });

                if (response.data?.success) {
                    // Update local state after successful API call
                    setAnswers(prev => ({
                        ...prev,
                        [questionId]: answer
                    }));
                } else {
                    console.error("Error submitting answer:", response.data?.message);
                    setNotification({
                        isOpen: true,
                        type: "error",
                        message: response.data?.message || "Không thể lưu câu trả lời"
                    });
                }
            }
        } catch (err) {
            console.error("Error submitting answer:", err);
            setNotification({
                isOpen: true,
                type: "error",
                message: "Không thể lưu câu trả lời"
            });
        }
    }, [quizAttempt, attemptId]);

    const handleSubmitQuiz = useCallback(async () => {
        // Prevent multiple submissions
        if (submitting) {
            console.log("Already submitting, skipping...");
            return;
        }

        try {
            setSubmitting(true);
            
            // Stop timer
            if (timerIntervalRef.current) {
                clearInterval(timerIntervalRef.current);
                timerIntervalRef.current = null;
            }
            
            // Clear tất cả debounce timers
            Object.values(saveAnswerTimeoutRef.current).forEach(timeout => {
                if (timeout) clearTimeout(timeout);
            });
            saveAnswerTimeoutRef.current = {};

            // Đợi tất cả các answer đang save hoàn thành
            const waitForSaving = async () => {
                let retries = 0;
                while (savingAnswersRef.current.size > 0 && retries < 20) {
                    await new Promise(resolve => setTimeout(resolve, 100));
                    retries++;
                }
            };
            await waitForSaving();
            
            // Submit answer của câu hiện tại trước khi nộp bài (nếu chưa được save)
            if (currentQuestion) {
                const questionId = currentQuestion.questionId || currentQuestion.QuestionId;
                const currentAnswer = answers[questionId];
                
                // Nếu có đáp án và chưa được save, submit ngay
                if (currentAnswer !== undefined && currentAnswer !== null && !savingAnswersRef.current.has(questionId)) {
                    await handleSubmitAnswer(questionId, currentAnswer);
                }
            }

            const currentAttemptId = quizAttempt?.attemptId || quizAttempt?.AttemptId || attemptId;
            
            if (!currentAttemptId) {
                setNotification({
                    isOpen: true,
                    type: "error",
                    message: "Không tìm thấy attempt ID"
                });
                setSubmitting(false);
                return;
            }

            console.log("=== Submitting Quiz Attempt ===");
            console.log("Attempt ID:", currentAttemptId);
            console.log("Quiz ID:", quizId);
            console.log("Current answers:", answers);
            console.log("Quiz Attempt:", quizAttempt);
            
            // Log API endpoint
            const submitEndpoint = `/user/quiz-attempts/${currentAttemptId}/submit`;
            console.log("API Endpoint:", submitEndpoint);
            // Note: Full URL is built by axiosClient with baseURL
            console.log("Submit endpoint:", submitEndpoint);
            console.log("Method: POST");
            console.log("Request body: (empty - POST with no body)");
            
            try {
                console.log("Calling quizAttemptService.submit...");
                const response = await quizAttemptService.submit(currentAttemptId);
                console.log("✓ Submit API Response received");
                console.log("Response Status:", response.status);
                console.log("Response Headers:", response.headers);
                console.log("Response Data:", JSON.stringify(response.data, null, 2));
                
                if (response.data?.success) {
                const resultData = response.data.data;
                
                setNotification({
                    isOpen: true,
                    type: "success",
                    message: "Nộp bài thành công!"
                });
                
                // Save result to localStorage
                localStorage.setItem(`quiz_result_${currentAttemptId}`, JSON.stringify(resultData));
                
                // Xóa quiz progress khỏi localStorage vì đã submit
                const quizIdToRemove = quizAttempt?.quizId || quizAttempt?.QuizId || quizId;
                if (quizIdToRemove) {
                    localStorage.removeItem(`quiz_in_progress_${quizIdToRemove}`);
                    console.log("🗑️ [QuizDetail] Quiz progress removed from localStorage (submitted) for quizId:", quizIdToRemove);
                }
                
                // Navigate to results page with result data
                setTimeout(() => {
                    navigate(`/course/${courseId}/lesson/${lessonId}/module/${moduleId}/quiz/${quizId}/attempt/${currentAttemptId}/results`, {
                        state: { result: resultData }
                    });
                }, 1500);
                } else {
                    console.error("✗ Submit failed - Response not successful");
                    console.error("Response data:", response.data);
                    console.error("Status code:", response.status);
                    
                    setNotification({
                        isOpen: true,
                        type: "error",
                        message: response.data?.message || "Không thể nộp bài"
                    });
                    setSubmitting(false);
                }
            } catch (apiErr) {
                console.error("✗ API Error submitting quiz:", apiErr);
                console.error("Error details:", {
                    message: apiErr.message,
                    response: apiErr.response,
                    status: apiErr.response?.status,
                    data: apiErr.response?.data,
                    config: apiErr.config
                });
                
                setNotification({
                    isOpen: true,
                    type: "error",
                    message: apiErr.response?.data?.message || apiErr.message || "Không thể nộp bài. Vui lòng kiểm tra console để xem chi tiết lỗi."
                });
                setSubmitting(false);
            }
        } catch (err) {
            console.error("✗ Unexpected error in handleSubmitQuiz:", err);
            console.error("Error stack:", err.stack);
            setNotification({
                isOpen: true,
                type: "error",
                message: err.message || "Có lỗi xảy ra khi nộp bài. Vui lòng thử lại."
            });
            setSubmitting(false);
        } finally {
            setShowSubmitModal(false);
        }
    }, [submitting, currentQuestion, answers, handleSubmitAnswer, quizAttempt, attemptId, quizId, courseId, lessonId, moduleId, navigate]);

    const calculateAndUpdateRemainingTime = useCallback(() => {
        if (!endTimeRef.current) {
            console.log("⚠️ endTimeRef.current is null, cannot calculate remaining time");
            setRemainingTime(null);
            return;
        }

        try {
            const now = new Date();
            const endTime = endTimeRef.current;
            
            // Calculate remaining time in seconds (real-time)
            const remaining = Math.max(0, Math.floor((endTime - now) / 1000));
            setRemainingTime(remaining);

            // Auto-submit if time is up (chỉ submit một lần)
            if (remaining <= 0 && !autoSubmitCalledRef.current && !submitting) {
                console.log("⏰ Time is up! Auto-submitting quiz...");
                autoSubmitCalledRef.current = true; // Đánh dấu đã gọi để tránh gọi lại
                
                if (timerIntervalRef.current) {
                    clearInterval(timerIntervalRef.current);
                    timerIntervalRef.current = null;
                }
                
                // Call handleSubmitQuiz to auto-submit (chỉ gọi một lần)
                handleSubmitQuiz();
            }
        } catch (error) {
            console.error("❌ Error calculating remaining time:", error);
            setRemainingTime(null);
        }
    }, [submitting, handleSubmitQuiz]);

    const startTimer = useCallback(() => {
        // Clear existing timer if any
        if (timerIntervalRef.current) {
            clearInterval(timerIntervalRef.current);
        }
        
        // Start timer to update remainingTime every second
        timerIntervalRef.current = setInterval(() => {
            timeSpentRef.current += 1;
            
            // Update remainingTime real-time
            calculateAndUpdateRemainingTime();
        }, 1000);
        
        console.log("✅ Timer started");
    }, [calculateAndUpdateRemainingTime]);

    // Function to calculate and set endTime from startedAt + Duration
    const calculateEndTime = useCallback(() => {
        console.log("🔍 calculateEndTime called");
        console.log("quizAttempt:", quizAttempt);
        console.log("quiz:", quiz);
        
        if (!quizAttempt || !quiz) {
            console.warn("⚠️ Missing quizAttempt or quiz");
            endTimeRef.current = null;
            return;
        }

        // Get quiz duration (in minutes) - handle both camelCase and PascalCase
        const quizDuration = quiz.Duration !== undefined ? quiz.Duration : (quiz.duration !== undefined ? quiz.duration : null);
        console.log("📊 Quiz Duration:", quizDuration, "type:", typeof quizDuration);
        
        if (quizDuration === null || quizDuration === undefined || isNaN(quizDuration) || quizDuration <= 0) {
            console.warn("⚠️ Invalid or missing quizDuration:", quizDuration);
            endTimeRef.current = null; // No time limit
            return;
        }

        // Get StartedAt from attempt - handle both camelCase and PascalCase
        const startedAtStr = quizAttempt.StartedAt || quizAttempt.startedAt;
        console.log("📅 StartedAt string:", startedAtStr);
        
        if (!startedAtStr) {
            console.warn("⚠️ StartedAt not found in quizAttempt");
            endTimeRef.current = null;
            return;
        }

        try {
            const startedAt = new Date(startedAtStr);
            if (isNaN(startedAt.getTime())) {
                console.error("❌ Invalid StartedAt date:", startedAtStr);
                endTimeRef.current = null;
                return;
            }
            
            // Calculate endTime = startedAt + Duration (minutes)
            // Use exact duration from backend (no extra buffer)
            const durationMs = Number(quizDuration) * 60 * 1000;
            const endTime = new Date(startedAt.getTime() + durationMs);
            endTimeRef.current = endTime;
            
            console.log("✅ === Timer Calculation ===");
            console.log("StartedAt:", startedAt.toISOString());
            console.log("Duration:", quizDuration, "minutes");
            console.log("Duration (ms):", durationMs);
            console.log("EndTime:", endTime.toISOString());
            console.log("Now:", new Date().toISOString());
            console.log("============================");
        } catch (err) {
            console.error("❌ Error calculating endTime:", err);
            endTimeRef.current = null;
        }
    }, [quizAttempt, quiz]);

    // Calculate endTime when quizAttempt or quiz changes
    useEffect(() => {
        if (quizAttempt && quiz) {
            console.log("🔄 Calculating endTime and starting timer...");
            calculateEndTime();
            // Calculate remaining time immediately
            calculateAndUpdateRemainingTime();
            
            // Start timer if not already started
            if (!timerIntervalRef.current) {
                startTimer();
            }
        }
        
        // Cleanup timer on unmount
        return () => {
            if (timerIntervalRef.current) {
                clearInterval(timerIntervalRef.current);
                timerIntervalRef.current = null;
            }
        };
    }, [quizAttempt, quiz, calculateEndTime, calculateAndUpdateRemainingTime, startTimer]);

    const handleAnswerChange = (questionId, answer) => {
        // Cập nhật local state ngay lập tức để UI responsive
        setAnswers(prev => ({
            ...prev,
            [questionId]: answer
        }));

        // Auto-save với debounce (500ms) - Backend sẽ chấm điểm ngay lập tức
        const currentAttemptId = quizAttempt?.attemptId || quizAttempt?.AttemptId || attemptId;
        if (!currentAttemptId || !questionId) {
            return;
        }

        // Clear timeout cũ nếu có
        if (saveAnswerTimeoutRef.current[questionId]) {
            clearTimeout(saveAnswerTimeoutRef.current[questionId]);
        }

        // Nếu đang save answer này, skip
        if (savingAnswersRef.current.has(questionId)) {
            return;
        }

        // Debounce: Đợi 500ms sau khi user ngừng thay đổi
        saveAnswerTimeoutRef.current[questionId] = setTimeout(async () => {
            try {
                savingAnswersRef.current.add(questionId);
                
                console.log(`💾 [AutoSave] Saving answer for question ${questionId}:`, answer);
                const response = await quizAttemptService.updateAnswer(currentAttemptId, {
                    questionId,
                    userAnswer: answer
                });

                if (response.data?.success) {
                    const newScore = response.data?.data; // Backend trả về score của câu này
                    console.log(`✅ [AutoSave] Answer saved successfully. Score: ${newScore}`);
                    // Không cần update state vì đã update ở trên
                } else {
                    console.error("❌ [AutoSave] Error saving answer:", response.data?.message);
                    // Không hiển thị notification để tránh làm phiền user
                    // Chỉ log để debug
                }
            } catch (err) {
                console.error("❌ [AutoSave] Error saving answer:", err);
                // Không hiển thị notification để tránh làm phiền user
            } finally {
                savingAnswersRef.current.delete(questionId);
                delete saveAnswerTimeoutRef.current[questionId];
            }
        }, 500); // Debounce 500ms
    };

    const handleNext = async () => {
        // Clear debounce timer cho câu hiện tại và đợi save hoàn thành
        if (currentQuestion) {
            const questionId = currentQuestion.questionId || currentQuestion.QuestionId;
            
            // Clear debounce timer nếu có
            if (saveAnswerTimeoutRef.current[questionId]) {
                clearTimeout(saveAnswerTimeoutRef.current[questionId]);
                delete saveAnswerTimeoutRef.current[questionId];
            }

            // Đợi answer này save xong (nếu đang save)
            if (savingAnswersRef.current.has(questionId)) {
                let retries = 0;
                while (savingAnswersRef.current.has(questionId) && retries < 10) {
                    await new Promise(resolve => setTimeout(resolve, 100));
                    retries++;
                }
            }

            // Nếu answer chưa được save, save ngay
            const currentAnswer = answers[questionId];
            if (currentAnswer !== undefined && currentAnswer !== null && !savingAnswersRef.current.has(questionId)) {
                await handleSubmitAnswer(questionId, currentAnswer);
            }
        }

        // Chuyển sang câu tiếp theo
        if (currentQuestionIndex < questions.length - 1) {
            setCurrentQuestionIndex(prev => prev + 1);
        }
    };

    const handlePrevious = async () => {
        // Clear debounce timer cho câu hiện tại và đợi save hoàn thành
        if (currentQuestion) {
            const questionId = currentQuestion.questionId || currentQuestion.QuestionId;
            
            // Clear debounce timer nếu có
            if (saveAnswerTimeoutRef.current[questionId]) {
                clearTimeout(saveAnswerTimeoutRef.current[questionId]);
                delete saveAnswerTimeoutRef.current[questionId];
            }

            // Đợi answer này save xong (nếu đang save)
            if (savingAnswersRef.current.has(questionId)) {
                let retries = 0;
                while (savingAnswersRef.current.has(questionId) && retries < 10) {
                    await new Promise(resolve => setTimeout(resolve, 100));
                    retries++;
                }
            }

            // Nếu answer chưa được save, save ngay
            const currentAnswer = answers[questionId];
            if (currentAnswer !== undefined && currentAnswer !== null && !savingAnswersRef.current.has(questionId)) {
                await handleSubmitAnswer(questionId, currentAnswer);
            }
        }

        // Chuyển sang câu trước
        if (currentQuestionIndex > 0) {
            setCurrentQuestionIndex(prev => prev - 1);
        }
    };

    const handleGoToQuestion = async (index) => {
        // Clear debounce timer cho câu hiện tại và đợi save hoàn thành
        if (currentQuestion && index !== currentQuestionIndex) {
            const questionId = currentQuestion.questionId || currentQuestion.QuestionId;
            
            // Clear debounce timer nếu có
            if (saveAnswerTimeoutRef.current[questionId]) {
                clearTimeout(saveAnswerTimeoutRef.current[questionId]);
                delete saveAnswerTimeoutRef.current[questionId];
            }

            // Đợi answer này save xong (nếu đang save)
            if (savingAnswersRef.current.has(questionId)) {
                let retries = 0;
                while (savingAnswersRef.current.has(questionId) && retries < 10) {
                    await new Promise(resolve => setTimeout(resolve, 100));
                    retries++;
                }
            }

            // Nếu answer chưa được save, save ngay
            const currentAnswer = answers[questionId];
            if (currentAnswer !== undefined && currentAnswer !== null && !savingAnswersRef.current.has(questionId)) {
                await handleSubmitAnswer(questionId, currentAnswer);
            }
        }

        // Chuyển sang câu được chọn
        setCurrentQuestionIndex(index);
    };

    if (loading) {
        return (
            <>
                <MainHeader />
                <div className="quiz-detail-container">
                    <div className="loading-message">Đang tải...</div>
                </div>
            </>
        );
    }

    if (error && !quizAttempt) {
        return (
            <>
                <MainHeader />
                <div className="quiz-detail-container">
                    <div className="error-message">{error || "Không thể tải thông tin quiz"}</div>
                    {quizId && (
                        <div style={{ marginTop: "20px", textAlign: "center" }}>
                            <Button
                                variant="primary"
                                onClick={() => {
                                    fetchedKeyRef.current = null;
                                    fetchQuizAttempt();
                                }}
                            >
                                Thử lại
                            </Button>
                        </div>
                    )}
                </div>
            </>
        );
    }

    if (!quizAttempt) {
        return (
            <>
                <MainHeader />
                <div className="quiz-detail-container">
                    <div className="loading-message">Đang tải thông tin quiz...</div>
                </div>
            </>
        );
    }

    // Tính thời gian làm bài
    // Backend trả về Duration (phút), StartedAt, TimeSpentSeconds
    const quizDuration = quiz?.Duration || quiz?.duration; // Phút
    const timeLimit = quizDuration ? (quizDuration * 60 + 10) : null; // Convert minutes to seconds + 10s buffer
    
    // Debug logs
    console.log("=== Timer Debug ===");
    console.log("quiz:", quiz);
    console.log("quizDuration:", quizDuration, "minutes");
    console.log("timeLimit:", timeLimit, "seconds");
    console.log("quizAttempt:", quizAttempt);
    console.log("remainingTime state:", remainingTime);
    console.log("===================");

    return (
        <>
            <MainHeader />
            <div className="quiz-detail-container">
                <Container fluid>
                    <Row>
                        <Col lg={9}>
                            <div className="quiz-content">
                                <div className="quiz-header">
                                    <h2 className="quiz-title">{quiz?.title || "Quiz"}</h2>
                                    {quiz?.description && (
                                        <p className="quiz-description">{quiz.description}</p>
                                    )}
                                </div>

                                {questions.length === 0 ? (
                                    <div className="no-question-message">
                                        <p>Đang tải câu hỏi...</p>
                                        <p className="text-muted">Vui lòng đợi trong giây lát.</p>
                                    </div>
                                ) : currentQuestion ? (
                                    <QuestionCard
                                        question={currentQuestion}
                                        answer={answers[currentQuestion.questionId || currentQuestion.QuestionId]}
                                        onChange={(answer) => handleAnswerChange(currentQuestion.questionId || currentQuestion.QuestionId, answer)}
                                        questionNumber={currentQuestionIndex + 1}
                                        totalQuestions={questions.length}
                                    />
                                ) : (
                                    <div className="no-question-message">
                                        Không có câu hỏi nào
                                    </div>
                                )}

                                <div className="quiz-navigation-buttons d-flex justify-content-between">
                                    <Button
                                        variant="outline-secondary"
                                        onClick={handlePrevious}
                                        disabled={currentQuestionIndex === 0}
                                    >
                                        Câu trước
                                    </Button>
                                    {currentQuestionIndex < questions.length - 1 ? (
                                        <Button
                                            className="btn-next-question"
                                            onClick={handleNext}
                                        >
                                            Câu tiếp theo
                                        </Button>
                                    ) : (
                                        <Button
                                            className="btn-complete-quiz"
                                            onClick={() => setShowSubmitModal(true)}
                                        >
                                            Hoàn thành
                                        </Button>
                                    )}
                                </div>
                            </div>
                        </Col>
                        <Col lg={3}>
                            <div className="quiz-sidebar d-flex flex-column">
                                <QuizTimer
                                    timeLimit={timeLimit}
                                    remainingTime={remainingTime}
                                    onTimeUp={() => {
                                        // Chỉ gọi một lần
                                        if (!autoSubmitCalledRef.current && !submitting) {
                                            autoSubmitCalledRef.current = true;
                                            setNotification({
                                                isOpen: true,
                                                type: "warning",
                                                message: "Hết thời gian làm bài!"
                                            });
                                            handleSubmitQuiz();
                                        }
                                    }}
                                />
                                
                                <QuizNavigation
                                    questions={questions}
                                    currentIndex={currentQuestionIndex}
                                    answers={answers}
                                    onGoToQuestion={handleGoToQuestion}
                                />

                                <div className="quiz-submit-section">
                                    <Button
                                        size="lg"
                                        className="submit-quiz-btn"
                                        onClick={() => setShowSubmitModal(true)}
                                        disabled={submitting}
                                    >
                                        {submitting ? "Đang nộp..." : "Nộp bài"}
                                    </Button>
                                </div>
                            </div>
                        </Col>
                    </Row>
                </Container>
            </div>

            <ConfirmModal
                isOpen={showSubmitModal}
                onClose={() => setShowSubmitModal(false)}
                onConfirm={handleSubmitQuiz}
                title="Xác nhận nộp bài"
                message="Bạn có chắc chắn muốn nộp bài? Sau khi nộp, bạn không thể chỉnh sửa câu trả lời."
                confirmText="Nộp bài"
                cancelText="Hủy"
                type="warning"
            />

            <NotificationModal
                isOpen={notification.isOpen}
                onClose={() => setNotification({ ...notification, isOpen: false })}
                type={notification.type}
                message={notification.message}
            />
        </>
    );
}

