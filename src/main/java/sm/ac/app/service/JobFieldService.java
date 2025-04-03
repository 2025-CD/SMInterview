package sm.ac.app.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import sm.ac.app.dto.JobFieldDto;

import sm.ac.app.frame.InterviewService;
import sm.ac.app.repository.JobFieldRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class JobFieldService implements InterviewService<String, JobFieldDto> {
    //인터페이스가 될 수 없다.
    //보통 controller가 호출하기 때문.
    //RequiredArgsConstructor를 써주면 CustService 객체가 생성될때 자동으로 custRepository 생성
    //RequiredArgsContructor를 사용하면, 필드를 final로..
    final JobFieldRepository jobFieldRepository;

    @Override
    public void add(JobFieldDto jobFieldDto) throws Exception {
        jobFieldRepository.insert(jobFieldDto);



    }

    @Override
    public void modify(JobFieldDto jobFieldDto) throws Exception {
        jobFieldRepository.update(jobFieldDto);


    }

    @Override
    public void del(String s) throws Exception {
        jobFieldRepository.delete(s);

    }

    @Override
    public JobFieldDto get(String s) throws Exception {
        return jobFieldRepository.selectOne(s);
    }

    @Override
    public List<JobFieldDto> get() throws Exception {
        return jobFieldRepository.select();
    }

//    public List<CustDto> findByName(String name) throws Exception {
//        return usersRepository.findByName(name);
//    }
//
//    public Page<CustDto> getPage(int pageNo) throws Exception {
//        PageHelper.startPage(pageNo,5);
//        return usersRepository.getpage();
//    }
//
//    public boolean hasPurchasedPT(String custId) {
//        return usersRepository.hasPurchasedPT(custId) > 0;
//    }



}
